# Token (JWT) authentication + simple role-based authorization.
#
#   class TodosController < ApplicationController            # every action needs a token
#   allow_unauthenticated_access only: %i[login signup]      # opt out per action
#   require_role :admin                                      # restrict by role
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!
    attr_reader :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :authenticate!, **options
    end

    def require_role(*roles, **options)
      before_action(**options) { authorize_roles!(*roles) }
    end
  end

  private

  def authenticate!
    payload = JsonWebToken.decode(bearer_token)
    @current_user = User.find_by(id: payload[:sub])

    raise ApiError::Unauthorized, "Account not found" unless current_user
    raise ApiError::Unauthorized, "Your guest session has expired" if current_user.guest_expired?
  end

  def authorize_roles!(*roles)
    return if roles.map(&:to_s).include?(current_user.role)

    raise ApiError::Forbidden, "This action requires one of these roles: #{roles.join(', ')}"
  end

  def bearer_token
    request.authorization.to_s[/\ABearer (.+)\z/, 1]
  end
end
