# Thin wrapper around the `jwt` gem.
module JsonWebToken
  ALGORITHM = "HS256".freeze
  MEMBER_TTL = 24.hours

  module_function

  def issue_for(user)
    expires_at = user.guest? ? user.guest_expires_at : MEMBER_TTL.from_now
    encode({ sub: user.id, role: user.role }, expires_at:)
  end

  def encode(payload, expires_at:)
    JWT.encode(payload.merge(exp: expires_at.to_i), secret, ALGORITHM)
  end

  # Returns the payload hash, or raises ApiError::Unauthorized.
  def decode(token)
    raise ApiError::Unauthorized if token.blank?

    payload, _header = JWT.decode(token, secret, true, algorithm: ALGORITHM)
    payload.with_indifferent_access
  rescue JWT::ExpiredSignature
    raise ApiError::Unauthorized, "Your session has expired, please log in again"
  rescue JWT::DecodeError
    raise ApiError::Unauthorized, "Invalid token"
  end

  def secret
    ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
  end
end
