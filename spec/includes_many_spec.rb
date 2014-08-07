require 'spec_helper'

class SQLCounter
  attr_accessor :log, :ignore

  def initialize
    @log = []
    @ignore = [/^PRAGMA (?!(table_info))/,
               /^SELECT currval/, /^SELECT CAST/,
               /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/,
               /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/,
               /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/,
               /^BEGIN/, /^COMMIT/]
  end

  def call(name, start, finish, message_id, values)
    sql = values[:sql]
    return if 'CACHE' == values[:name] || ignore.any? { |x| x =~ sql }
    @log << sql
  end
end

RSpec.describe IncludesMany do
  describe 'self_siblings_and_children' do
    let(:parent) { Comment.create! :body => 'some comment' }
    let(:child1) { Comment.create! :body => 'child1', :parent => parent }
    let(:child2) { Comment.create! :body => 'child2', :parent => parent }
    let(:child3) { Comment.create! :body => 'child3', :parent => parent }
    let(:subchild11) { Comment.create! :body => 'subchild11', :parent => child1 }
    let(:subchild12) { Comment.create! :body => 'subchild12', :parent => child1 }
    let(:subchild21) { Comment.create! :body => 'subchild21', :parent => child2 }
    let(:subchild31) { Comment.create! :body => 'subchild31', :parent => child3 }

    let(:subscriber) { SQLCounter.new }

    before do
      Comment.find_each(&:destroy)
      subchild11
      subchild12
      subchild21
      subchild31
      ActiveSupport::Notifications.subscribe('sql.active_record', subscriber)
    end

    it 'works' do
      expect(child1.self_siblings_and_children.map(&:body).sort).to eq ["child1", "child2", "child3", "subchild11", "subchild12"]
      expect(child2.self_siblings_and_children.map(&:body).sort).to eq ["child1", "child2", "child3", "subchild21"]
      expect(child3.self_siblings_and_children.map(&:body).sort).to eq ["child1", "child2", "child3", "subchild31"]
    end

    it 'executes N+1 if not used includes' do
      expect {
        childs = Comment.where("body like 'child%'").order('body ASC')
        expect(childs.map(&:self_siblings_and_children).map(&:size).flatten).to eq [5, 4, 4]
      }.to change { subscriber.log.size } .from(0).to(4)
    end

    it 'includes relation' do
      expect {
        childs = Comment.where("body like 'child%'").order('body ASC').includes(:self_siblings_and_children)
        expect(childs.map(&:self_siblings_and_children).map(&:size).flatten).to eq [5, 4, 4]
      }.to change { subscriber.log.size } .from(0).to(2)

      expect(subscriber.log.first).to match Regexp.new( #Regexp.escape(
        %q{SELECT "comments".* FROM "comments"\s+WHERE \(body like 'child%'\)\s+ORDER BY body ASC}
      )

      expect(subscriber.log.last).to match Regexp.new( #Regexp.escape(
        %q{SELECT "comments".* FROM "comments"\s+WHERE "comments"."parent_id" IN}
      )
    end

    it 'denies join on includes_many' do
      expect {
        Comment.where("body like 'child%'").order('body ASC').joins(:self_siblings_and_children).to_a
      }.to raise_error(
        ActiveRecord::NonScalarPrimaryKeyError,
        /Can not join association :self_siblings_and_children, because :primary_key is a callable/
      )
    end
  end
end
