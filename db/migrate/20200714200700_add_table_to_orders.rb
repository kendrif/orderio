class AddTableToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :Table, :string
  end
end
