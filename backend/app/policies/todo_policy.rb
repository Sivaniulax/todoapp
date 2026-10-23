class TodoPolicy < ApplicationPolicy
  def index? = true
  # Everyone in the workspace can read its todos; only the author and an
  # admin can change one.
  def show? = true
  def create? = true # the guest limit is a model validation
  def update? = owner? || user.admin?
  def destroy? = owner? || user.admin?
  def destroy_completed? = true
  def history? = show?

  # A status change is an edit like any other.
  alias_method :start?, :update?
  alias_method :complete?, :update?
  alias_method :reopen?, :update?
  alias_method :archive?, :update?
  alias_method :trash?, :update?
  alias_method :restore?, :update?

  # acts_as_tenant has already narrowed this to the current workspace.
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
