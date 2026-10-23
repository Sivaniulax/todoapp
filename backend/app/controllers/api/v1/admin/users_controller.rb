module Api
  module V1
    module Admin
      class UsersController < BaseController
        # GET /api/v1/admin/users?page=1
        def index
          authorize User, :index?
          users, meta = paginate(policy_scope(User).newest_first)
          render json: { users: UserResource.new(users).serializable_hash, meta: }
        end
      end
    end
  end
end
