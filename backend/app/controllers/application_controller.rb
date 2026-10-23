class ApplicationController < ActionController::API
  include ErrorHandling
  include Authentication
  include Pundit::Authorization
  include Pagination

  # Every query for a tenant model is scoped to this workspace from here on.
  set_current_tenant_through_filter
  before_action :set_workspace

  # Catches an action that forgot to call authorize.
  after_action :verify_authorized

  private

  def set_workspace
    set_current_tenant(current_user&.workspace)
  end
end
