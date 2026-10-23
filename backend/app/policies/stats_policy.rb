# Authorizes the :stats symbol - there is no record behind the dashboard.
class StatsPolicy < ApplicationPolicy
  def show? = user.admin?
end
