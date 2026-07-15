require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "active scope excludes inactive products" do
    assert_includes Product.active, products(:mug)
    assert_not_includes Product.active, products(:discontinued_tee)
  end

  test "requires a positive price" do
    product = products(:mug).dup
    product.price_cents = 0

    assert_not product.valid?
  end

  test "requires a unique sku" do
    duplicate = products(:mug).dup

    assert_not duplicate.valid?
  end

  test "formatted_price renders naira from kobo" do
    assert_equal "₦3,500.00", products(:mug).formatted_price
  end
end
