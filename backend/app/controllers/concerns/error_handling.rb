# Turns exceptions into consistent JSON errors:
#   { "error": "Validation failed", "details": { "title": ["can't be blank"] } }
module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |error|
      render_error("#{error.model || 'Record'} not found", :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render_error("Validation failed", :unprocessable_content, details: error.record.errors.to_hash)
    end

    rescue_from ActionController::ParameterMissing do |error|
      render_error(error.message, :bad_request)
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
