class CategoryPolicy < ApplicationPolicy
  # Guests get an empty list rather than a 403.
  def index? = true
  def create? = user.can_manage_categories?
  def update? = create? && (owner? || user.admin?)
  def destroy? = update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
