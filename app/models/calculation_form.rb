class CalculationForm
  include ActiveModel::Model

  MONTH_ORDER_ERROR = "From month must be the same as or earlier than to month."

  attr_accessor :price, :borough, :from_date, :to_date
  attr_reader :result

  validates :price, :borough, :from_date, :to_date, presence: true
  validate :validate_months_and_order

  def self.with_defaults
    new(price: "", borough: "Oxford", from_date: "2000-01", to_date: "2016-01")
  end

  def calculate
    @result = nil
    return false unless valid?

    @result = InflatedPriceCalculator.new.call(
      price: price, borough: borough, from_date: from_date, to_date: to_date
    )
    true
  rescue InflatedPriceCalculator::InvalidInput,
         InflatedPriceCalculator::UnknownArea,
         InflatedPriceCalculator::IndexUnavailable => error
    errors.add(:base, error.message)
    false
  end

  def self.human_attribute_name(attribute, options = {})
    labels = { from_date: "From month", to_date: "To month", borough: "Area" }
    labels[attribute.to_sym] || super
  end

  private

  def validate_months_and_order
    from_month = parse_month(:from_date)
    to_month = parse_month(:to_date)
    errors.add(:base, MONTH_ORDER_ERROR) if from_month && to_month && from_month > to_month
  end

  def parse_month(attribute)
    value = public_send(attribute)
    return if value.blank?

    HpiMonth.parse(value)
  rescue HpiMonth::Invalid => error
    errors.add(attribute, error.message)
    nil
  end
end
