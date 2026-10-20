# Custom exceptions that map straight to HTTP statuses.
# Raise them anywhere in a request and ErrorHandling renders the JSON.
class ApiError < StandardError
  def status = :internal_server_error

  class Unauthorized < ApiError
    def initialize(message = "You need to log in")
      super
    end

    def status = :unauthorized
  end

  class Forbidden < ApiError
    def initialize(message = "You are not allowed to do that")
      super
    end

    def status = :forbidden
  end
end
