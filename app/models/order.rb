class Order < ApplicationRecord
    has_many :line_items, dependent: :destroy
    validates :name, presence: true

    enum type: {
      "Table Service" => "1",
      "Collection" => "2"
  }

  
    def add_line_items_from_cart(cart)
      cart.line_items.each do |item|
        item.cart_id = nil
        line_items << item
      end
    end
  
end