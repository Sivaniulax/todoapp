class ApplicationController < ActionController::API
  include ErrorHandling
  include Authentication
  include Pundit::Authorization
  include Pagination
  # Rails only wires this into ActionController::Base, and paper_trail leaves
  # whodunnit opt-in, so an API app asks for both.
  include PaperTrail::Rails::Controller

  # Every query for a tenant model is scoped to this workspace from here on.
  set_current_tenant_through_filter
  before_action :set_workspace
  before_action :set_paper_trail_whodunnit

  # Catches an action that forgot to call authorize.
  after_action :verify_authorized

  private

  def set_workspace
    set_current_tenant(current_user&.workspace)
  end

  # PaperTrail stamps every version with whoever was signed in.
  def user_for_paper_trail
    current_user&.id
  end
end
