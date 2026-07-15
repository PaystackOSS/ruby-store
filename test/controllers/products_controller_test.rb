require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index lists only active products" do
    get products_path

    assert_response :success
    assert_match products(:mug).name, response.body
    assert_no_match products(:discontinued_tee).name, response.body
  end

  test "show renders an active product" do
    get product_path(products(:mug))

    assert_response :success
    assert_match products(:mug).name, response.body
  end

  test "show 404s for an inactive product" do
    get product_path(products(:discontinued_tee))

    assert_response :not_found
  end
end
