require "test_helper"

class CalculationsPageTest < ActionDispatch::IntegrationTest
  test "the home page shows an accessible form with local assets and Stimulus hooks" do
    get "/"

    assert_response :success
    assert_select "h1", text: "Compare a property price across time"
    assert_select "form[action='/calculate'][method='post'][data-controller='inflation-form']"
    assert_select "input[name='calculation_form[price]'][data-inflation-form-target='price']"
    assert_select "select[name='calculation_form[borough]'] option", text: "Oxford"
    assert_select "input[name='calculation_form[from_date]'][type='month'][max='2016-01'][data-action='change->inflation-form#validateDates']"
    assert_select "input[name='calculation_form[to_date]'][type='month'][min='2000-01'][data-action='change->inflation-form#validateDates']"
    assert_select "button[data-action='click->inflation-form#useExample']", text: "Quick Example"
    assert_select "link[rel='stylesheet'][href*='bootstrap.min']"
    assert_select "script[type='importmap']"
  end

  test "submitting the form shows the calculated result and retains the input" do
    post "/calculate", params: { calculation_form: {
      price: "100000", borough: "Islington", from_date: "2000-01", to_date: "2016-01"
    } }

    assert_response :success
    assert_select "#calculation-result .result-amount", text: "£366,726"
    assert_select "#calculation-result", text: /28\.25.*103\.60/m
    assert_select "input[name='calculation_form[price]'][value='100000']"
    assert_select "select[name='calculation_form[borough]'] option[selected='selected']", text: "Islington"
  end

  test "invalid price shows a form error and preserves the entered value" do
    post "/calculate", params: { calculation_form: {
      price: "-1", borough: "Oxford", from_date: "2000-01", to_date: "2016-01"
    } }

    assert_response :unprocessable_entity
    assert_select "[role='alert']", text: /price must be a non-negative decimal amount/
    assert_select "input[name='calculation_form[price]'][value='-1']"
    assert_select "#calculation-result", count: 0
  end

  test "an unavailable month shows a form error" do
    post "/calculate", params: { calculation_form: {
      price: "100000", borough: "Oxford", from_date: "2000-01", to_date: "2016-06"
    } }

    assert_response :unprocessable_entity
    assert_select "[role='alert']", text: "No HPI index for Oxford in 2016-06"
    assert_select "#calculation-result", count: 0
  end

  test "the page rejects a from month later than the to month" do
    post "/calculate", params: { calculation_form: {
      price: "100000", borough: "Islington", from_date: "2016-01", to_date: "2000-01"
    } }

    assert_response :unprocessable_entity
    assert_select "[role='alert']", text: CalculationForm::MONTH_ORDER_ERROR
    assert_select "input[name='calculation_form[from_date]'][value='2016-01'][max='2000-01']"
    assert_select "input[name='calculation_form[to_date]'][value='2000-01'][min='2016-01']"
    assert_select "#calculation-result", count: 0
  end

  test "the page accepts the same from and to month" do
    post "/calculate", params: { calculation_form: {
      price: "100000", borough: "Islington", from_date: "2000-01", to_date: "2000-01"
    } }

    assert_response :success
    assert_select "#calculation-result .result-amount", text: "£100,000"
    assert_select "input[name='calculation_form[from_date]'][max='2000-01']"
    assert_select "input[name='calculation_form[to_date]'][min='2000-01']"
    assert_select "[role='alert']", count: 0
  end
end
