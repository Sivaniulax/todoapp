# Wraps Devise so controllers keep one line of vocabulary:
#
#   allow_unauthenticated_access only: %i[login signup]
#
# Devise supplies current_user and the session; what is left is the guest
# expiry rule. Authorization is Pundit's job, not this concern's.
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :authenticate!, **options
    end
  end

  private

  def authenticate!
    raise ApiError::Unauthorized unless user_signed_in?
    return unless current_user.guest_expired?

    sign_out(current_user)
    raise ApiError::Unauthorized, I18n.t("api.errors.guest_session_expired")
  end
end
