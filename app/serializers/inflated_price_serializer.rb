class InflatedPriceSerializer
  include ActiveSupport::NumberHelper

  def initialize(result)
    @result = result
  end

  def as_json(*)
    {
      borough: @result.borough,
      from_date: @result.from_month.to_s,
      to_date: @result.to_month.to_s,
      price: @result.original_price.to_s("F"),
      from_index: number_to_rounded(@result.from_index, precision: 2),
      to_index: number_to_rounded(@result.to_index, precision: 2),
      inflated_price: @result.inflated_price,
      currency: "GBP"
    }
  end
end
