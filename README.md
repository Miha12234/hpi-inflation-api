# UK House Price Index price calculator

A Rails application with a browser calculator and a JSON API. Both adjust a
property price between two months using the supplied UK HPI snapshot
(`data/UK-HPI-2016-05.csv`). The CSV is bundled with the application, so there
is no database or import step.

## Packaging

Download a source ZIP from [GitHub](https://github.com/Miha12234/hpi-inflation-api/archive/refs/heads/main.zip)
or [GitLab](https://gitlab.com/Miha12234/hpi-inflation-api/-/archive/main/hpi-inflation-api-main.zip).
If the ZIP is stored beside this project folder, you can also
[download the locally packaged ZIP](../hpi_inflation_api.zip) and send it to the
recipient. These ZIPs contain the Rails code, CSV, page assets, tests, and
`Gemfile.lock` (the gem versions). Local secrets and runtime files are omitted.

If you edit the project and need a **new** ZIP, open a terminal inside the
`hpi_inflation_api` folder and run:

```sh
python3 bin/package.py
```

That command writes `hpi_inflation_api.zip` in the folder containing the
project folder. For example, a project at `/home/miha/project/hpi_inflation_api`
produces `/home/miha/project/hpi_inflation_api.zip`. The recipient does not run
this packaging command; they unzip the file and follow the steps below.

## Run after unzipping

Install Ruby 3.3.0 and Bundler 2.5 or newer. Then, in the folder created by
unzipping the project, run:

```sh
bundle install
bundle exec rails server
```

Open `http://localhost:3000` to use the calculator. `GET /up` checks that Rails
is running. Ruby gems are downloaded by `bundle install` on a machine that does
not already have them. No API key, database, Node.js setup, or environment file
is needed for local development.

Run the tests with:

```sh
bundle exec rails test
```

The test suite covers the browser form, its results and errors, the JSON API,
and the calculation service. It uses Rails' built-in Minitest integration, so
no extra test framework setup is required.

## Use the browser page

At `http://localhost:3000`, enter the original price in pounds, choose an area,
select the from and to months, and click **Calculate price**. The from month
must be the same as or earlier than the to month; equal months are allowed.
The page shows the adjusted price and the two HPI indices used. Invalid inputs
display an error while keeping the entered values. **Quick Example** fills in
the Islington values from the specification; click **Calculate price** to see
£366,726.

The page uses locally bundled Bootstrap CSS and a basic Stimulus controller for
the example button, month-order feedback, and submit feedback. The calculation
and error display are rendered by Rails, so the form also works when JavaScript
is unavailable.

## Use the JSON API

Send JSON to `POST /api/v1/inflated_prices`:

```sh
curl -X POST http://localhost:3000/api/v1/inflated_prices \
  -H 'Content-Type: application/json' \
  -d '{"price":"100000","borough":"Islington","from_date":"2000-01","to_date":"2016-01"}'
```

Response (`200 OK`):

```json
{
  "borough": "Islington",
  "from_date": "2000-01",
  "to_date": "2016-01",
  "price": "100000.0",
  "from_index": "28.25",
  "to_index": "103.60",
  "inflated_price": 366726,
  "currency": "GBP"
}
```

`price` is a non-negative decimal amount; send it as a JSON string to preserve
decimal precision. `borough` is matched case-insensitively against the CSV's
`RegionName` column. Dates must be ISO months (`YYYY-MM`) or the first day of a
month (`YYYY-MM-01`). The JSON API still accepts reverse date ranges and can
produce a lower price; the month-order rule applies only to the browser page.

The CSV holds monthly data from January 1995 through May 2016 for nine areas.
`GET /api/v1/areas` lists the accepted names. The service reads the `Index`
column, rounds each index to two decimal places as in the specification's
Islington example, multiplies the input price by `to_index / from_index`, then
rounds the result to the nearest whole pound (half up). The unrounded values
in the CSV would yield a different answer for that example; the two-decimal
rule is intentional so the response matches the requested £366,726.

Invalid input returns `422` with `error.code = "invalid_input"`. An unknown
area returns `404` with `error.code = "unknown_borough"`; a month without data
returns `404` with `error.code = "index_unavailable"`. Errors have this shape:

```json
{"error":{"code":"index_unavailable","message":"No HPI index for Oxford in 2016-06"}}
```

## Code organization

`HpiMonth` parses month input for both interfaces. `CalculationForm` uses
ActiveModel validations for browser-only rules, including the from/to order.
`InflatedPriceCalculator` handles the index ratio and returns an immutable
`InflatedPriceResult` with numeric values. The ERB page formats that result for
people; `InflatedPriceSerializer` formats the same result for the JSON API.
`HpiIndexRepository` reads the bundled CSV and can be replaced with another
data source without changing the calculation.
