module Api
  module V1
    class MeController < ApplicationController
      # GET /api/v1/me
      def show
        authorize current_user, :show?
        render json: { user: UserResource.new(current_user).serializable_hash }
      end
    end
  end
end
