require 'spec_helper'

RSpec.describe IncludesMany do
  describe 'in rails 3.2' do
    let(:parent) { Comment.create! :body => 'some comment' }
    let(:child1) { Comment.create! :body => 'child1', :parent => parent }
    let(:child2) { Comment.create! :body => 'child2', :parent => parent }
    let(:subchild1) { Comment.create! :body => 'subchild1', :parent => child1 }

    before do
      Comment.find_each(&:destroy)
      subchild1
      child2
    end

    it 'works' do
      expect(child1.self_siblings_and_children.map(&:body).sort).to eq ["child1", "child2", "subchild1"]
    end
  end
end
