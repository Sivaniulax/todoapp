class TodoPolicy < ApplicationPolicy
  def index? = true
  def show? = true # the scope already hides other people's todos
  def create? = true # the guest limit is a model validation
  def update? = owner?
  def destroy? = owner?
  def destroy_completed? = true

  # A status change is an edit like any other.
  alias_method :start?, :update?
  alias_method :complete?, :update?
  alias_method :reopen?, :update?
  alias_method :archive?, :update?
  alias_method :trash?, :update?
  alias_method :restore?, :update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.todos
    end
  end
end
