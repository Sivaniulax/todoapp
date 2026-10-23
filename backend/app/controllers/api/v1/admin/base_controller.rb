module Api
  module V1
    module Admin
      # The dashboard reports on the whole installation, so admin controllers
      # step outside the current workspace on purpose.
      class BaseController < ApplicationController
        around_action :across_all_workspaces

        private

        def across_all_workspaces(&block)
          ActsAsTenant.without_tenant(&block)
        end
      end
    end
  end
end
