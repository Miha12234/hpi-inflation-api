module Api
  module V1
    class AreasController < ActionController::API
      def index
        render json: { areas: HpiIndexRepository.default.areas }
      end
    end
  end
end
