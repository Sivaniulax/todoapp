# Turns exceptions into the same JSON shape everywhere:
#   { "error": "Validation failed", "details": { "title": ["can't be blank"] } }
module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |error|
      render_error(I18n.t("api.errors.not_found", model: error.model || "Record"), :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render_error(I18n.t("api.errors.validation_failed"), :unprocessable_content,
                   details: error.record.errors.to_hash)
    end

    # Optimistic locking: two people edited the same todo.
    rescue_from ActiveRecord::StaleObjectError do
      render_error(I18n.t("api.errors.stale_object"), :conflict)
    end

    rescue_from ActionController::ParameterMissing do |error|
      render_error(error.message, :bad_request)
    end

    rescue_from Pundit::NotAuthorizedError do |error|
      render_error(I18n.t("api.errors.forbidden"), :forbidden,
                   details: { required: error.query.to_s.delete_suffix("?") })
    end

    rescue_from ApiError do |error|
      render_error(error.message, error.status)
    end
  end

  private

  def render_error(message, status, details: nil)
    body = { error: message }
    body[:details] = details if details.present?
    render json: body, status:
  end
end
