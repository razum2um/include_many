ActiveRecord::Schema.define do
  create_table(:comments, :force => true) do |t|
    t.string :body
    t.integer :parent_id
  end
end
