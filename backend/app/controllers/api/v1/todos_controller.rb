module Api
  module V1
    class TodosController < ApplicationController
      before_action :set_todo, only: %i[show update destroy toggle]

      # GET /api/v1/todos?status=pending&q=milk&priority=high&category_id=1&sort=due_date&page=1&per_page=10
      def index
        query = TodosQuery.new(current_user.todos.includes(:category), filter_params)
        todos, meta = paginate(query.call)

        render json: { todos: TodoSerializer.many(todos), meta: meta.merge(counts: query.counts) }
      end

      # GET /api/v1/todos/:id
      def show
        render json: { todo: TodoSerializer.new(@todo).as_json }
      end

      # POST /api/v1/todos
      def create
        todo = current_user.todos.create!(todo_params)
        render json: { todo: TodoSerializer.new(todo).as_json }, status: :created
      end

      # PATCH /api/v1/todos/:id
      def update
        @todo.update!(todo_params)
        render json: { todo: TodoSerializer.new(@todo).as_json }
      end

      # DELETE /api/v1/todos/:id
      def destroy
        @todo.destroy!
        head :no_content
      end

      # PATCH /api/v1/todos/:id/toggle
      def toggle
        @todo.toggle_completion!
        render json: { todo: TodoSerializer.new(@todo).as_json }
      end

      # DELETE /api/v1/todos/clear_completed
      def clear_completed
        deleted = current_user.todos.completed.destroy_all
        render json: { deleted_count: deleted.size }
      end

      private

      # Scoping through current_user means other people's todos are a 404.
      def set_todo
        @todo = current_user.todos.find(params[:id])
      end

      def todo_params
        params.expect(todo: %i[title description due_date priority category_id completed])
      end

      def filter_params
        params.permit(:status, :q, :priority, :category_id, :sort)
      end
    end
  end
end
