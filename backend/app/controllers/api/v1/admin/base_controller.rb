module Api
  module V1
    module Admin
      # Admin controllers authorize against their own policy; this only
      # groups them under one parent.
      class BaseController < ApplicationController
      end
    end
  end
end
