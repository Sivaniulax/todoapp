module RequestHelpers
  def json
    response.parsed_body
  end
end
