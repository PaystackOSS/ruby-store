class Order < ApplicationRecord
  belongs_to :product

  enum :status, { pending: 0, paid: 1, failed: 2 }
  serialize :paystack_response, coder: JSON

  validates :reference, presence: true, uniqueness: true
  validates :email, presence: true

  # Idempotent: whichever confirmation path (redirect callback or webhook) arrives
  # second is a no-op, since both key off the same unique `reference`.
  def mark_paid!(payload)
    with_lock { update!(status: :paid, paid_at: Time.current, paystack_response: payload) unless paid? }
  end

  def mark_failed!(payload)
    with_lock { update!(status: :failed, paystack_response: payload) unless paid? }
  end
end
