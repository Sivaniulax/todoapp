module Api
  module V1
    class AuthController < ApplicationController
      allow_unauthenticated_access only: %i[signup login guest]
      require_role :guest, only: :upgrade

      # Built-in Rails 8 rate limiting (uses Rails.cache).
      rate_limit to: 10, within: 3.minutes, only: %i[signup login guest],
                 with: -> { render_error("Too many attempts. Try again in a few minutes.", :too_many_requests) }

      # POST /api/v1/auth/signup
      def signup
        user = User.create!(account_params.merge(role: :member))
        render json: auth_payload(user), status: :created
      end

      # POST /api/v1/auth/login
      def login
        user = User.authenticate_by(email: params[:email].to_s, password: params[:password].to_s)
        raise ApiError::Unauthorized, "Invalid email or password" if user.nil? || user.guest?

        render json: auth_payload(user)
      end

      # POST /api/v1/auth/guest
      def guest
        user = User.create_guest!
        CleanupExpiredGuestsJob.perform_later # tidy up old guests in the background
        render json: auth_payload(user), status: :created
      end

      # POST /api/v1/auth/upgrade  (guest -> member, keeps todos)
      def upgrade
        user = Accounts::UpgradeGuest.call(current_user, account_params)
        render json: auth_payload(user)
      end

      private

      # Rails 8 `params.expect`: strong params that also reject a wrong shape with 400.
      def account_params
        params.expect(user: %i[name email password password_confirmation])
      end

      def auth_payload(user)
        { token: JsonWebToken.issue_for(user), user: UserSerializer.new(user).as_json }
      end
    end
  end
end
