module Api
  module V1
    module Admin
      class StatsController < BaseController
        # GET /api/v1/admin/stats
        def show
          users_by_role = User.group(:role).count # => { "guest" => 3, "member" => 10, "admin" => 1 }
          total_todos = Todo.count
          completed_todos = Todo.completed.count

          render json: {
            users: {
              total: users_by_role.values.sum,
              guests: users_by_role.fetch("guest", 0),
              members: users_by_role.fetch("member", 0),
              admins: users_by_role.fetch("admin", 0)
            },
            todos: {
              total: total_todos,
              completed: completed_todos,
              overdue: Todo.overdue.count,
              completion_rate: total_todos.zero? ? 0 : (completed_todos * 100.0 / total_todos).round(1)
            }
          }
        end
      end
    end
  end
end
