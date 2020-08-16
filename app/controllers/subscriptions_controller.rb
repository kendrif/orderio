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
    fee = @order.amount * 1
  
    token = params[:stripeToken]
    customer = Stripe::Customer.create(email: @order.email, source: token)
 
    begin

     Stripe::PaymentIntent.create({
       customer: customer,
       amount: (charge).to_i, 
       confirm: true,
       currency: 'gbp',
       payment_method_types: ['card'],
       application_fee_amount: (fee).to_i,
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

      OrderFiniJob.perform_now(@order)
      OrderMailer.recived(@order).deliver_now
      redirect_to session.delete(:return_to), notice: "Your order has been successful 👌🏼"

      rescue Stripe::CardError => e
      puts "Status is: #{e.http_status}"
      puts "Type is: #{e.error.type}"
        puts "Charge ID is: #{e.error.charge}"
        # The following fields are optional
        puts "Code is: #{e.error.code}" if e.error.code
        puts "Decline code is: #{e.error.decline_code}" if e.error.decline_code
        puts "Param is: #{e.error.param}" if e.error.param
        puts "Message is: #{e.error.message}" if e.error.message
      rescue Stripe::RateLimitError => e
        # Too many requests made to the API too quickly
      rescue Stripe::InvalidRequestError => e
        # Invalid parameters were supplied to Stripe's API
      rescue Stripe::AuthenticationError => e
        # Authentication with Stripe's API failed
        # (maybe you changed API keys recently)
      rescue Stripe::APIConnectionError => e
        # Network communication with Stripe failed
      rescue Stripe::StripeError => e
        # Display a very generic error to the user, and maybe send
        # yourself an email
      rescue => e

      rescue ActiveRecord::RecordNotFound
          # handle not found error
          format.html { redirect_to new_subscription_path(:account_id => @account, :amount => @order.amount, :order => @order), notice: "There has been an issue. Errorcode: 333" }
        rescue ActiveRecord::ActiveRecordError
          # handle other ActiveRecord errors
          format.html { redirect_to new_subscription_path(:account_id => @account, :amount => @order.amount, :order => @order), notice: "There has been an issue. Errorcode: 444" }
        rescue # StandardError
          format.html { redirect_to new_subscription_path(:account_id => @account, :amount => @order.amount, :order => @order), notice: "There has been an issue. Errorcode: 555" }
        rescue Exception
          format.html { redirect_to new_subscription_path(:account_id => @account, :amount => @order.amount, :order => @order), notice: "There has been an issue. Errorcode: 666" }
    end

  end

end