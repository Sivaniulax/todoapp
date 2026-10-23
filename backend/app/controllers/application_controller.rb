class ApplicationController < ActionController::API
  include ErrorHandling
  include Authentication
  include Pundit::Authorization
  include Pagination

  # Catches an action that forgot to call authorize.
  after_action :verify_authorized
end
