require "test_helper"
require "minitest/mock"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test "create builds a pending order and redirects to the authorization url" do
    product = products(:mug)

    with_stubbed_paystack(initialize_result: fake_result(authorization_url: "https://checkout.paystack.com/abc123")) do
      assert_difference("Order.count", 1) do
        post orders_path, params: { product_id: product.id, email: "buyer@example.com" }
      end
    end

    order = Order.last
    assert order.pending?
    assert_equal product, order.product
    assert_redirected_to "https://checkout.paystack.com/abc123"
  end

  test "callback marks the order paid on a successful verification" do
    order = orders(:pending_order)

    with_stubbed_paystack(verify_result: fake_result(status: "success")) do
      get callback_orders_path(reference: order.reference)
    end

    assert_response :success
    assert order.reload.paid?
  end

  test "callback marks the order failed on an unsuccessful verification" do
    order = orders(:pending_order)

    with_stubbed_paystack(verify_result: fake_result(status: "failed")) do
      get callback_orders_path(reference: order.reference)
    end

    assert_response :success
    assert order.reload.failed?
  end

  private

  # `paystack.transaction.initialize(...)` mirrors the gem's real API shape, so the double
  # needs a callable `initialize` method (shadowing Ruby's constructor, on this one instance only).
  def with_stubbed_paystack(initialize_result: nil, verify_result: nil, &block)
    transaction_double = Object.new
    transaction_double.define_singleton_method(:initialize) { |*_args| initialize_result }
    transaction_double.define_singleton_method(:verify) { |*_args| verify_result }

    client_double = Object.new
    client_double.define_singleton_method(:transaction) { transaction_double }

    Paystack::Client.stub(:new, client_double, &block)
  end

  def fake_result(data)
    Struct.new(:data).new(data)
  end
end
