ActiveRecord::Schema.define(:version => 1) do
  create_table :companies, :force => true do |t|
    t.column :name, :string
  end

  create_table :users, :force => true do |t|
    t.column :name, :string
    t.column :company_id, :integer
  end

  create_table :tenants, :force => true do |t|
    t.column :name, :string
    t.column :schema_name, :string
  end

  create_table :items, :force => true do |t|
    t.column :name, :string
  end
end