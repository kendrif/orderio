class SubscriptionsController < ApplicationController

  def new
    @account = User.find_by_id(params[:account_id])
    @order = Order.find(params[:order])
  end

  # Reference:
  # https://stripe.com/docs/connect/subscriptions
  def create
    
    @account = User.find_by_id(params[:account_id])
    key = @account.access_code
    Stripe.api_key = key
    account_suid = @account.uid
    @order = Order.find(params[:order])
    charge = @order.amount * 100
    fee = @order.amount * 1.5
  
    token = params[:stripeToken]
    customer = Stripe::Customer.create(email: @order.email, source: token)
 
     Stripe::PaymentIntent.create({
       customer: customer,
       amount: (charge).to_i, 
       confirm: true,
       currency: 'gbp',
       payment_method_types: ['card'],
       application_fee_amount: (feecharge).to_i,
     }, {
       stripe_account: account_suid
     })
    options = {
      stripe_id: customer.id
    }

    options.merge!(
      card_last4: params[:user][:card_last4],
      card_exp_month: params[:user][:card_exp_month],
      card_exp_year: params[:user][:card_exp_year],
      card_type: params[:user][:card_brand]
    )

    OrderMailer.recived(@order).deliver_now
    OrderFiniJob.perform_now(@order)
    redirect_to session.delete(:return_to), notice: "Your order has been successful 👌🏼"


    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_subscription_path(:account_id => @account, :amount => @order.amount, :order => @order), notice: "There has been an error with your payment. Please try again."
    
  end

end
