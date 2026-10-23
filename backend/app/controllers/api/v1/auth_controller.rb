module Api
  module V1
    class AuthController < ApplicationController
      allow_unauthenticated_access only: %i[signup login guest]
      # Signing in is not an authorized action: there is nobody to authorize.
      skip_after_action :verify_authorized, only: %i[signup login guest]

      # Needs a real cache store, see config/environments/development.rb.
      rate_limit to: 10, within: 3.minutes, only: %i[signup login guest],
                 with: -> { render_error(I18n.t("api.errors.too_many_attempts"), :too_many_requests) }

      # POST /api/v1/auth/signup
      def signup
        user = User.create!(account_params.merge(role: :member))
        sign_in(user)
        render json: auth_payload(user), status: :created
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email].to_s.strip.downcase)
        unless user&.valid_password?(params[:password].to_s) && !user.guest?
          raise ApiError::Unauthorized, I18n.t("api.errors.invalid_credentials")
        end

        sign_in(user)
        render json: auth_payload(user)
      end

      # DELETE /api/v1/auth/logout
      def logout
        authorize current_user, :show?
        sign_out(current_user)
        head :no_content
      end

      # POST /api/v1/auth/guest
      def guest
        user = User.create_guest!
        sign_in(user)
        CleanupExpiredGuestsJob.perform_later # tidy up old guests in the background
        render json: auth_payload(user), status: :created
      end

      # POST /api/v1/auth/upgrade  (guest -> member, keeps todos)
      def upgrade
        authorize current_user, :upgrade?
        user = Accounts::UpgradeGuest.call(current_user, account_params)
        # A new password means a new session salt, so re-sign them in.
        bypass_sign_in(user)
        render json: auth_payload(user)
      end

      private

      def account_params
        params.expect(user: %i[name email password password_confirmation])
      end

      def auth_payload(user)
        { user: UserResource.new(user).serializable_hash }
      end
    end
  end
end
