require "test_helper"

class CalculationFormTest < ActiveSupport::TestCase
  test "the form reports an invalid month through ActiveModel errors" do
    form = CalculationForm.new(
      price: "100000", borough: "Oxford", from_date: "2000-13", to_date: "2016-01"
    )

    assert_not form.calculate
    assert_includes form.errors.full_messages, "From month must be a valid calendar month"
    assert_nil form.result
  end

  test "a valid form stores a numeric calculation result" do
    form = CalculationForm.new(
      price: "100000", borough: "Islington", from_date: "2000-01", to_date: "2016-01"
    )

    assert form.calculate
    assert_instance_of InflatedPriceResult, form.result
    assert_equal 366_726, form.result.inflated_price
  end
end
