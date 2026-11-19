require "date"

# A month in the HPI dataset. Both the form and calculator use the same parser.
class HpiMonth
  include Comparable

  class Invalid < StandardError; end

  FORMAT = /\A(\d{4})-(\d{2})(?:-01)?\z/

  attr_reader :date

  def self.parse(value)
    match = FORMAT.match(value.to_s)
    raise Invalid, "must be YYYY-MM or YYYY-MM-01" unless match

    new(Date.new(match[1].to_i, match[2].to_i, 1))
  rescue Date::Error
    raise Invalid, "must be a valid calendar month"
  end

  def initialize(date)
    @date = Date.new(date.year, date.month, 1)
    freeze
  end

  def <=>(other)
    date <=> other.date if other.is_a?(HpiMonth)
  end

  def to_s
    date.strftime("%Y-%m")
  end
end
