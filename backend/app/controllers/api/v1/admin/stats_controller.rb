module Api
  module V1
    module Admin
      class StatsController < BaseController
        CACHE_TTL = 5.minutes

        # GET /api/v1/admin/stats
        # Counting every row on each request is wasteful, so the result is
        # cached. `fetch` runs the block only on a miss.
        def show
          authorize :stats, :show?
          stats = Rails.cache.fetch("admin/stats", expires_in: CACHE_TTL) { build_stats }
          render json: stats
        end

        private

        def build_stats
          users_by_role = User.group(:role).count
          total_todos = Todo.kept.count
          completed_todos = Todo.kept.completed.count

          {
            users: {
              total: users_by_role.values.sum,
              guests: users_by_role.fetch("guest", 0),
              members: users_by_role.fetch("member", 0),
              admins: users_by_role.fetch("admin", 0)
            },
            todos: {
              total: total_todos,
              completed: completed_todos,
              overdue: Todo.kept.overdue.count,
              trashed: Todo.trashed.count,
              completion_rate: total_todos.zero? ? 0 : (completed_todos * 100.0 / total_todos).round(1)
            }
          }
        end
      end
    end
  end
end
