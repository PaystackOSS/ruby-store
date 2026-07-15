# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# price_cents is in kobo, the lowest currency unit for NGN (Paystack's `amount` field expects this same unit) —
# e.g. 350_000 kobo == ₦3,500.00. This is the single most common mistake when integrating Paystack.
products = [
  {
    sku: "MUG-001",
    name: "Ruby Red Mug",
    description: "A sturdy ceramic mug for your morning coffee, in classic Ruby red.",
    price_cents: 350_000,
    image_url: "https://images.pexels.com/photos/8091186/pexels-photo-8091186.jpeg"
  },
  {
    sku: "TEE-001",
    name: "Ruby Red Tee",
    description: "Soft cotton t-shirt with cool theme printed on the front.",
    price_cents: 1_200_000,
    image_url: "https://images.pexels.com/photos/36827355/pexels-photo-36827355.jpeg"
  },
  {
    sku: "HOD-001",
    name: "Hotwire Hoodie",
    description: "A cozy hoodie for late-night Stimulus controller debugging.",
    price_cents: 2_500_000,
    image_url: "https://images.pexels.com/photos/29652516/pexels-photo-29652516.jpeg"
  },
  {
    sku: "STK-001",
    name: "Sticker Pack",
    description: "A pack of 10 assorted stickers for your laptop.",
    price_cents: 150_000,
    image_url: "https://images.pexels.com/photos/11035359/pexels-photo-11035359.jpeg"
  }
]

products.each do |attrs|
  Product.find_or_create_by!(sku: attrs[:sku]) do |product|
    product.assign_attributes(attrs)
  end
end
