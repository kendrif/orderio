class AddTypeToCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :Type, :string
  end
end
