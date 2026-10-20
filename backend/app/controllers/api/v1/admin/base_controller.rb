module Api
  module V1
    module Admin
      # Every controller under /api/v1/admin inherits the admin-only rule.
      class BaseController < ApplicationController
        require_role :admin
      end
    end
  end
end
