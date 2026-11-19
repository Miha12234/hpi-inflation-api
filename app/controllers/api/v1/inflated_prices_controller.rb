module Api
  module V1
    class InflatedPricesController < ActionController::API
      def create
        result = InflatedPriceCalculator.new.call(
          price: params[:price],
          borough: params[:borough],
          from_date: params[:from_date],
          to_date: params[:to_date]
        )
        render json: InflatedPriceSerializer.new(result).as_json, status: :ok
      rescue InflatedPriceCalculator::InvalidInput => error
        render_error("invalid_input", error.message, :unprocessable_entity)
      rescue InflatedPriceCalculator::UnknownArea => error
        render_error("unknown_borough", error.message, :not_found)
      rescue InflatedPriceCalculator::IndexUnavailable => error
        render_error("index_unavailable", error.message, :not_found)
      end

      private

      def render_error(code, message, status)
        render json: { error: { code: code, message: message } }, status: status
      end
    end
  end
end
