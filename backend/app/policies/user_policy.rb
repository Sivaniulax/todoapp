class UserPolicy < ApplicationPolicy
  def index? = user.admin?
  def show? = record == user || user.admin?
  def upgrade? = record == user && user.guest?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.admin? ? scope.all : scope.where(id: user.id)
    end
  end
end
