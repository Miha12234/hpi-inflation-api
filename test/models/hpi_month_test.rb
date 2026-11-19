require "test_helper"

class HpiMonthTest < ActiveSupport::TestCase
  test "ISO month and first-day date represent the same month" do
    month = HpiMonth.parse("2000-01")

    assert_equal month, HpiMonth.parse("2000-01-01")
    assert_equal "2000-01", month.to_s
    assert_operator month, :<, HpiMonth.parse("2016-01")
  end

  test "other day and invalid calendar month are rejected" do
    assert_raises(HpiMonth::Invalid) { HpiMonth.parse("2000-01-02") }
    assert_raises(HpiMonth::Invalid) { HpiMonth.parse("2000-13") }
  end
end
