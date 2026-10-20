module RequestHelpers
  def json
    response.parsed_body
  end

  def auth_headers(user)
    { "Authorization" => "Bearer #{JsonWebToken.issue_for(user)}" }
  end
end
