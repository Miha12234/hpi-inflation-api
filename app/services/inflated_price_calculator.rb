require "bigdecimal"

class InflatedPriceCalculator
  class InvalidInput < StandardError; end
  class UnknownArea < StandardError; end
  class IndexUnavailable < StandardError; end

  def initialize(repository: HpiIndexRepository.default)
    @repository = repository
  end

  def call(price:, borough:, from_date:, to_date:)
    amount = parse_price(price)
    from_month = parse_month(from_date, "from_date")
    to_month = parse_month(to_date, "to_date")
    raise InvalidInput, "borough is required" if borough.to_s.strip.empty?

    area = @repository.canonical_area(borough)
    raise UnknownArea, "Unknown borough: #{borough}" unless area

    from_index = lookup_index(area, from_month.to_s)
    to_index = lookup_index(area, to_month.to_s)

    # The specification's worked example uses indices displayed to 2 decimal
    # places, so round before taking the ratio to reproduce its answer.
    from_index = from_index.round(2, BigDecimal::ROUND_HALF_UP)
    to_index = to_index.round(2, BigDecimal::ROUND_HALF_UP)
    inflated = (amount * to_index / from_index).round(0, BigDecimal::ROUND_HALF_UP)

    InflatedPriceResult.new(
      borough: area,
      from_month: from_month,
      to_month: to_month,
      original_price: amount,
      from_index: from_index,
      to_index: to_index,
      inflated_price: inflated.to_i
    )
  end

  private

  def parse_price(value)
    text = value.to_s
    unless text.match?(/\A\d+(?:\.\d+)?\z/)
      raise InvalidInput, "price must be a non-negative decimal amount"
    end

    BigDecimal(text)
  end

  def parse_month(value, field)
    HpiMonth.parse(value)
  rescue HpiMonth::Invalid => error
    raise InvalidInput, "#{field} #{error.message}"
  end

  def lookup_index(area, month)
    @repository.index_for(area, month) ||
      raise(IndexUnavailable, "No HPI index for #{area} in #{month}")
  end

end
