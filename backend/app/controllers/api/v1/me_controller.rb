module Api
  module V1
    class MeController < ApplicationController
      # GET /api/v1/me
      def show
        render json: { user: UserSerializer.new(current_user).as_json }
      end
    end
  end
end
