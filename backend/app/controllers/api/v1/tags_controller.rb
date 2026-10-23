module Api
  module V1
    class TagsController < ApplicationController
      before_action :set_tag, only: :destroy

      # GET /api/v1/tags
      def index
        authorize Tag, :index?
        tags = policy_scope(Tag).alphabetical.includes(:taggings)
        render json: { tags: TagResource.new(tags).serializable_hash }
      end

      # DELETE /api/v1/tags/:id   (removes the tag and untags everything)
      def destroy
        @tag.destroy!
        head :no_content
      end

      private

      def set_tag
        @tag = policy_scope(Tag).find(params[:id])
        authorize @tag
      end
    end
  end
end
