class CategoryPolicy < ApplicationPolicy
  # Guests get an empty list rather than a 403.
  def index? = true
  def create? = user.can_manage_categories?
  def update? = create? && owner?
  def destroy? = update?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.categories
    end
  end
end
