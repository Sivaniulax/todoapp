module Api
  module V1
    class CategoriesController < ApplicationController
      before_action :set_category, only: %i[update destroy]

      # GET /api/v1/categories
      # Guests are allowed here and simply get an empty list.
      def index
        authorize Category, :index?
        render json: { categories: CategoryResource.new(policy_scope(Category).alphabetical).serializable_hash }
      end

      # POST /api/v1/categories
      def create
        authorize Category, :create?
        category = current_user.categories.create!(category_params)
        render json: { category: CategoryResource.new(category).serializable_hash }, status: :created
      end

      # PATCH /api/v1/categories/:id
      def update
        @category.update!(category_params)
        render json: { category: CategoryResource.new(@category).serializable_hash }
      end

      # DELETE /api/v1/categories/:id   (todos keep existing, without a category)
      def destroy
        @category.destroy!
        head :no_content
      end

      private

      def set_category
        @category = policy_scope(Category).find(params[:id])
        authorize @category
      end

      # The double array is how params.expect spells "a list of hashes".
      def category_params
        params.expect(category: [ :name, :color,
                                  { todos_attributes: [ %i[title description due_date priority] ] } ])
      end
    end
  end
end
