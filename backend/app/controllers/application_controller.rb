class ApplicationController < ActionController::API
  include ErrorHandling
  include Authentication
  include Pagination
end
