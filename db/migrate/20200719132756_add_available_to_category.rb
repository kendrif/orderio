class AddAvailableToCategory < ActiveRecord::Migration[6.0]
  def change
    add_column :categories, :available, :boolean, default: true
  end
end
