require "test_helper"

class PaystackWebhooksControllerTest < ActionDispatch::IntegrationTest
  test "rejects a request with a missing signature" do
    order = orders(:pending_order)

    post paystack_webhook_path, params: charge_success_payload(order.reference), as: :json

    assert_response :unauthorized
    assert order.reload.pending?
  end

  test "rejects a request with an invalid signature" do
    order = orders(:pending_order)

    post paystack_webhook_path,
      params: charge_success_payload(order.reference),
      headers: { "x-paystack-signature" => "not-the-real-signature" },
      as: :json

    assert_response :unauthorized
    assert order.reload.pending?
  end

  test "marks the order paid when the signature is valid" do
    order = orders(:pending_order)
    payload = charge_success_payload(order.reference).to_json
    signature = OpenSSL::HMAC.hexdigest("SHA512", ENV.fetch("PAYSTACK_SECRET_KEY"), payload)

    post paystack_webhook_path,
      params: payload,
      headers: { "CONTENT_TYPE" => "application/json", "x-paystack-signature" => signature }

    assert_response :ok
    assert order.reload.paid?
  end

  private

  def charge_success_payload(reference)
    { "event" => "charge.success", "data" => { "reference" => reference, "status" => "success" } }
  end
end
