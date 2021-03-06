class Category < ApplicationRecord
    validates :category, presence: true 
    validates :Type, presence: true 

    has_many :products
    belongs_to :user

    enum Type: {
        "Food Menu" => "food",
        "Drinks Menu" => "drink"
    }
end
