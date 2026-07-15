require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "mark_paid! sets status to paid and stamps paid_at" do
    order = orders(:pending_order)

    order.mark_paid!({ "status" => "success" })

    assert order.paid?
    assert_not_nil order.paid_at
  end

  test "mark_paid! is a no-op when the order is already paid" do
    order = orders(:paid_order)
    original_paid_at = order.paid_at

    order.mark_paid!({ "status" => "success" })

    assert_equal original_paid_at, order.reload.paid_at
  end

  test "mark_failed! never downgrades a paid order" do
    order = orders(:paid_order)

    order.mark_failed!({ "status" => "failed" })

    assert order.reload.paid?
  end

  test "mark_failed! marks a pending order as failed" do
    order = orders(:pending_order)

    order.mark_failed!({ "status" => "failed" })

    assert order.reload.failed?
  end

  test "requires a unique reference" do
    duplicate = orders(:pending_order).dup
    duplicate.reference = orders(:paid_order).reference

    assert_not duplicate.valid?
  end
end
