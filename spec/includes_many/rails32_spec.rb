require 'spec_helper'

RSpec.describe IncludesMany do
  describe 'in rails 3.2' do
    let(:comment) { Comment.create! :body => 'some comment' }

    before do
      Comment.find_each(&:destroy)
      comment
    end

    it 'works' do
      expect(Comment.count).to eq 1
    end
  end
end
