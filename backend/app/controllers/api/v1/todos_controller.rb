module Api
  module V1
    class TodosController < ApplicationController
      before_action :set_todo,
                    only: %i[show update destroy history start complete reopen archive trash restore]

      # GET /api/v1/todos?status=pending&q=milk&priority=high&category_id=1&tag=work&sort=due_date
      def index
        authorize Todo, :index?
        query = TodosQuery.new(scoped_todos, filter_params)
        todos, meta = paginate(query.call)

        render json: { todos: TodoResource.new(todos).serializable_hash, meta: meta.merge(counts: query.counts) }
      end

      # GET /api/v1/todos/trash
      def trashed
        authorize Todo, :index?
        todos, meta = paginate(policy_scope(Todo).trashed.includes(:category, :tags).order(discarded_at: :desc))
        render json: { todos: TodoResource.new(todos).serializable_hash, meta: }
      end

      # GET /api/v1/todos/:id
      def show
        render json: { todo: TodoResource.new(@todo).serializable_hash }
      end

      # POST /api/v1/todos
      def create
        authorize Todo, :create?
        todo = current_user.todos.create!(todo_params)
        render json: { todo: TodoResource.new(todo).serializable_hash }, status: :created
      end

      # POST /api/v1/todos/bulk   (one title per line in titles_text)
      def bulk
        authorize Todo, :create?
        form = Todos::BulkCreateForm.new(current_user, bulk_params)

        if form.save
          render json: { todos: TodoResource.new(form.todos).serializable_hash }, status: :created
        else
          render json: { error: I18n.t("api.errors.validation_failed"), details: form.errors.to_hash },
                 status: :unprocessable_content
        end
      end

      # PATCH /api/v1/todos/:id
      # Send the lock_version you read to get a 409 instead of silently
      # overwriting someone else's edit.
      def update
        @todo.update!(todo_params)
        render json: { todo: TodoResource.new(@todo).serializable_hash }
      end

      # GET /api/v1/todos/:id/history
      def history
        versions = @todo.versions.reorder(created_at: :desc).limit(50)
        render json: { versions: VersionResource.new(versions).serializable_hash }
      end

      # DELETE /api/v1/todos/:id   (permanent - use /trash to keep it recoverable)
      def destroy
        @todo.destroy!
        head :no_content
      end

      # PATCH /api/v1/todos/:id/start|complete|reopen|archive
      # One action per AASM event; the model decides whether it is allowed.
      def start = fire(:start)
      def complete = fire(:complete)
      def reopen = fire(:reopen)
      def archive = fire(:archive)

      # PATCH /api/v1/todos/:id/trash   (soft delete)
      def trash
        @todo.trash!
        render json: { todo: TodoResource.new(@todo).serializable_hash }
      end

      # PATCH /api/v1/todos/:id/restore
      def restore
        @todo.restore!
        render json: { todo: TodoResource.new(@todo).serializable_hash }
      end

      # DELETE /api/v1/todos/clear_completed
      def clear_completed
        authorize Todo, :destroy_completed?
        deleted = policy_scope(Todo).kept.completed.destroy_all
        render json: { deleted_count: deleted.size }
      end

      private

      # A refused transition is the client's mistake, not a server error.
      def fire(event)
        if @todo.public_send(:"#{event}!")
          render json: { todo: TodoResource.new(@todo).serializable_hash }
        else
          render json: { error: I18n.t("api.errors.invalid_transition", event:, status: @todo.status) },
                 status: :unprocessable_content
        end
      end

      def scoped_todos
        policy_scope(Todo).kept.includes(:category, :tags)
      end

      # Finding inside the policy scope makes someone else's todo a 404
      # rather than a 403, so the API never confirms it exists.
      def set_todo
        @todo = policy_scope(Todo).find(params[:id])
        authorize @todo
      end

      def todo_params
        params.expect(todo: [ :title, :description, :due_date, :priority, :category_id,
                              :completed, :lock_version, { tag_names: [] } ])
      end

      def bulk_params
        params.expect(todos: %i[titles_text priority category_id due_date])
      end

      def filter_params
        params.permit(:status, :q, :priority, :category_id, :tag, :sort)
      end
    end
  end
end
