class Communication < ApplicationRecord
    validates :name, :text, :email, :company, presence: true
end
