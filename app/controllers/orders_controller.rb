class OrdersController < ApplicationController
  def create
    product = Product.active.find(params[:product_id])
    order = Order.create!(
      product: product,
      email: params.require(:email),
      amount_cents: product.price_cents,
      currency: product.currency,
      reference: SecureRandom.uuid,
      status: :pending
    )

    result = paystack.transaction.initialize({
      email: order.email,
      amount: order.amount_cents,
      reference: order.reference,
      callback_url: callback_orders_url
    })
    
    redirect_to result.data[:authorization_url], allow_other_host: true

  rescue Paystack::Error => e
    Rails.logger.error("Error initializing transaction: #{e.class} - #{e.message}")
    order&.update(status: :failed)
    redirect_to product_path(product), alert: "Could not start checkout: #{e.message}"
  end

  def callback
    @order = Order.find_by!(reference: params[:reference] || params[:trxref])
    result = paystack.transaction.verify(@order.reference)

    if result.data[:status] == "success"
      @order.mark_paid!(result.data)
      render :success
    else
      @order.mark_failed!(result.data)
      render :failure
    end
  rescue Paystack::Error => e
    Rails.logger.error("Error verifying transaction #{@order&.reference}: #{e.class} - #{e.message}")
    @order&.mark_failed!({ "error" => e.message })
    render :failure
  end

  private

  def paystack
    Paystack::Client.new(ENV.fetch("PAYSTACK_SECRET_KEY"))
  end
end
