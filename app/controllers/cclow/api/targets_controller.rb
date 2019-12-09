module CCLOW
  module Api
    class TargetsController < CCLOWController
      def index
        geography = ::Geography.find_by(iso: params[:iso])
        render json: geography.targets.as_json(path: request.protocol + request.host)
      end
    end
  end
end
