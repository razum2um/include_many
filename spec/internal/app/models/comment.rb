class Comment < ::ActiveRecord::Base
  belongs_to :parent, :class_name => 'Comment', :foreign_key => :parent_id
  has_many :children, :class_name => 'Comment', :foreign_key => :parent_id
  has_many :self_siblings, :class_name => 'Comment',
     :foreign_key => :parent_id, :primary_key => :parent_id

  # includes_many :siblings_and_c, :class_name => 'Comment',
  #    :foreign_key => proc { :parent_id }, :primary_key => :id
  #
  includes_many :self_siblings_and_children, :class_name => 'Comment',
     :foreign_key => :parent_id, :primary_key => proc { |c| [c.parent_id, c.id] }
end
