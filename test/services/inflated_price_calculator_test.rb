require "test_helper"

class InflatedPriceCalculatorTest < ActiveSupport::TestCase
  test "a reversed date range can deflate the price" do
    result = InflatedPriceCalculator.new.call(
      price: "366726", borough: "Islington", from_date: "2016-01", to_date: "2000-01"
    )

    assert_equal 100_000, result.inflated_price
  end

  test "missing borough is a validation error" do
    error = assert_raises(InflatedPriceCalculator::InvalidInput) do
      InflatedPriceCalculator.new.call(
        price: "100000", borough: nil, from_date: "2000-01", to_date: "2016-01"
      )
    end

    assert_equal "borough is required", error.message
  end

  test "the calculator returns numeric values for either presentation layer" do
    result = InflatedPriceCalculator.new.call(
      price: "100000", borough: "Islington", from_date: "2000-01", to_date: "2016-01"
    )

    assert_instance_of InflatedPriceResult, result
    assert_equal BigDecimal("100000"), result.original_price
    assert_equal BigDecimal("28.25"), result.from_index
    assert_equal BigDecimal("103.60"), result.to_index
    assert_equal HpiMonth.parse("2000-01"), result.from_month
  end
end
