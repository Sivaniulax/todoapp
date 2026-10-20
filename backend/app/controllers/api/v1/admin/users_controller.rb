module Api
  module V1
    module Admin
      class UsersController < BaseController
        # GET /api/v1/admin/users?page=1
        def index
          users, meta = paginate(User.newest_first)
          render json: { users: UserSerializer.many(users), meta: }
        end
      end
    end
  end
end
