class PaystackWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.raw_post
    signature = request.headers["x-paystack-signature"].to_s
    computed = OpenSSL::HMAC.hexdigest("SHA512", ENV.fetch("PAYSTACK_SECRET_KEY"), payload)

    unless ActiveSupport::SecurityUtils.secure_compare(computed, signature)
      Rails.logger.error("Rejected Paystack webhook: signature mismatch")
      head :unauthorized and return
    end

    event = JSON.parse(payload)
    if event["event"] == "charge.success"
      Order.find_by(reference: event.dig("data", "reference"))&.mark_paid!(event["data"])
    end

    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error("Rejected Paystack webhook: invalid JSON payload - #{e.message}")
    head :bad_request
  end
end
