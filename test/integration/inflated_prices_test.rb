require "test_helper"

class InflatedPricesTest < ActionDispatch::IntegrationTest
  test "the specification's Islington example" do
    post "/api/v1/inflated_prices", params: {
      price: "100000", borough: "Islington", from_date: "2000-01", to_date: "2016-01"
    }, as: :json

    assert_response :success
    assert_equal({
      "borough" => "Islington", "from_date" => "2000-01", "to_date" => "2016-01",
      "price" => "100000.0", "from_index" => "28.25", "to_index" => "103.60",
      "inflated_price" => 366_726, "currency" => "GBP"
    }, response.parsed_body)
  end

  test "Oxford calculation and case-insensitive borough lookup" do
    post "/api/v1/inflated_prices", params: {
      price: "100000", borough: " oxford ", from_date: "2000-01-01", to_date: "2016-01-01"
    }, as: :json

    assert_response :success
    assert_equal "Oxford", response.parsed_body["borough"]
    assert_equal "35.48", response.parsed_body["from_index"]
    assert_equal "112.13", response.parsed_body["to_index"]
    assert_equal 316_037, response.parsed_body["inflated_price"]
  end

  test "the same month returns the original whole-pound price" do
    post "/api/v1/inflated_prices", params: {
      price: "100000.49", borough: "Islington", from_date: "2000-01", to_date: "2000-01"
    }, as: :json

    assert_response :success
    assert_equal 100_000, response.parsed_body["inflated_price"]
  end

  test "the JSON API still accepts a reverse date range" do
    post "/api/v1/inflated_prices", params: {
      price: "100000", borough: "Islington", from_date: "2016-01", to_date: "2000-01"
    }, as: :json

    assert_response :success
    assert_equal 27_268, response.parsed_body["inflated_price"]
  end

  test "invalid price and dates return structured 422 errors" do
    { price: "-1", from_date: "2000-13", to_date: "2016-02-02" }.each do |field, value|
      body = { price: "100000", borough: "Oxford", from_date: "2000-01", to_date: "2016-01" }
      post "/api/v1/inflated_prices", params: body.merge(field => value), as: :json

      assert_response :unprocessable_entity
      assert_equal "invalid_input", response.parsed_body.dig("error", "code")
    end
  end

  test "unknown borough and unavailable month return structured 404 errors" do
    body = { price: "100000", borough: "Oxford", from_date: "2000-01", to_date: "2016-01" }

    post "/api/v1/inflated_prices", params: body.merge(borough: "Atlantis"), as: :json
    assert_response :not_found
    assert_equal "unknown_borough", response.parsed_body.dig("error", "code")

    post "/api/v1/inflated_prices", params: body.merge(to_date: "2016-06"), as: :json
    assert_response :not_found
    assert_equal "index_unavailable", response.parsed_body.dig("error", "code")
  end

  test "area discovery returns names from the supplied data" do
    get "/api/v1/areas", as: :json

    assert_response :success
    assert_includes response.parsed_body["areas"], "Oxford"
    assert_includes response.parsed_body["areas"], "Islington"
    assert_equal 9, response.parsed_body["areas"].length
  end
end
