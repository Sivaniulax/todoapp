# Exceptions that map straight to an HTTP status. Raise one anywhere in a
# request and ErrorHandling renders it. Default messages are in en.yml.
class ApiError < StandardError
  def initialize(message = nil)
    super(message || I18n.t("api.errors.server_error"))
  end

  def status = :internal_server_error

  class Unauthorized < ApiError
    def initialize(message = nil)
      super(message || I18n.t("api.errors.unauthorized"))
    end

    def status = :unauthorized
  end

  class Forbidden < ApiError
    def initialize(message = nil)
      super(message || I18n.t("api.errors.forbidden"))
    end

    def status = :forbidden
  end
end
