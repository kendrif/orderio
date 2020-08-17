class CreateCommunications < ActiveRecord::Migration[6.0]
  def change
    create_table :communications do |t|
      t.string :name
      t.text :title
      t.text :text
      t.string :phone
      t.string :email
      t.string :company

      t.timestamps
    end
  end
end
