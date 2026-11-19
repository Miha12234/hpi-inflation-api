require "csv"
require "date"
require "bigdecimal"

# The supplied HPI snapshot is small enough to index once in each Rails process.
# Keeping the original CSV in the archive avoids a database setup/import step.
class HpiIndexRepository
  DATA_PATH = Rails.root.join("data", "UK-HPI-2016-05.csv")

  def self.default
    @default ||= new(path: DATA_PATH)
  end

  def initialize(path:)
    @areas = {}
    @indices = {}

    CSV.foreach(path, headers: true) do |row|
      area = row.fetch("RegionName").to_s.strip
      month = Date.strptime(row.fetch("Date"), "%d/%m/%Y").strftime("%Y-%m")
      index = BigDecimal(row.fetch("Index"))
      raise ArgumentError, "HPI index must be positive" unless index.positive?

      @areas[area.downcase] = area
      key = [area, month]
      raise ArgumentError, "Duplicate HPI index for #{area} in #{month}" if @indices.key?(key)

      @indices[key] = index
    end

    @areas.freeze
    @indices.freeze
  end

  def areas
    @areas.values.sort.freeze
  end

  def canonical_area(name)
    @areas[name.to_s.strip.downcase]
  end

  def index_for(area, month)
    @indices[[area, month]]
  end
end
