module Api
  module V1
    class CategoriesController < ApplicationController
      # Guests can list (they'll get an empty array) but not manage categories.
      require_role :member, :admin, except: :index
      before_action :set_category, only: %i[update destroy]

      # GET /api/v1/categories
      def index
        render json: { categories: CategorySerializer.many(current_user.categories.alphabetical) }
      end

      # POST /api/v1/categories
      def create
        category = current_user.categories.create!(category_params)
        render json: { category: CategorySerializer.new(category).as_json }, status: :created
      end

      # PATCH /api/v1/categories/:id
      def update
        @category.update!(category_params)
        render json: { category: CategorySerializer.new(@category).as_json }
      end

      # DELETE /api/v1/categories/:id   (todos keep existing, without a category)
      def destroy
        @category.destroy!
        head :no_content
      end

      private

      def set_category
        @category = current_user.categories.find(params[:id])
      end

      def category_params
        params.expect(category: %i[name color])
      end
    end
  end
end
