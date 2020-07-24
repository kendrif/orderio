class AddContactNumToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :contactnum, :string
  end
end
