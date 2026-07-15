class Product < ApplicationRecord
  has_many :orders

  validates :name, :sku, presence: true
  validates :sku, uniqueness: true
  validates :price_cents, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  # price_cents is in kobo (the lowest currency unit), matching what Paystack's API expects.
  def formatted_price
    ActiveSupport::NumberHelper.number_to_currency(price_cents / 100.0, unit: currency == "NGN" ? "₦" : "#{currency} ")
  end
end
