class StoreController < ApplicationController
  before_action :set_account, only: [:show]

  include CurrentCart
  before_action :set_cart

  def index
    @products = Product.order(:title)
  end

  def menu
    @account = User.find_by_id(params[:id])
    @products = Product.order(:title)

     if request.fullpath.include?('Food') 
    @categories = Category.where(user_id: @account.id, Type: 'food').order(:category)
     else 
    @categories = Category.where(user_id: @account.id, Type: 'drink').order(:category)
     end


      if request.fullpath.include?('Food') 
     @categories = Category.where(user_id: @account.id, Type: 'food').order(:category)
      else 
         if request.fullpath.include?('Drink')
      @categories = Category.where(user_id: @account.id, Type: 'drink').order(:category)
     else 
      @categories = Category.where(user_id: @account.id).order(:category)
      end 
   end

    render layout: false
  end

  def profile
    @products = Product.order(:title)
    @categories = Category.where(user_id: @account.id).order(:category)
    @account = User.find_by_subdomain!(request.subdomain)
    render layout: false
  end

  def products
    @products = Product.order(:title)
  end

end
