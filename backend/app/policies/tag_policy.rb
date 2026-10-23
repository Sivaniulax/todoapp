class TagPolicy < ApplicationPolicy
  def index? = true
  def destroy? = user.can_manage_categories? && owner?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
