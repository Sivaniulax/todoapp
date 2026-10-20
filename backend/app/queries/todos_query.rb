# Query object: turns request params into a chain of scopes.
# Keeps the controller thin and is easy to unit test.
#
#   TodosQuery.new(user.todos, status: "pending", q: "milk", sort: "due_date").call
class TodosQuery
  STATUSES = %w[all pending completed overdue].freeze

  SORTS = {
    "newest" => { created_at: :desc },
    "oldest" => { created_at: :asc },
    "due_date" => Arel.sql("todos.due_date ASC NULLS LAST, todos.created_at DESC"),
    "priority" => Arel.sql("todos.priority DESC, todos.created_at DESC")
  }.freeze

  def initialize(scope, params = {})
    @scope = scope
    @params = params.to_h.symbolize_keys
  end

  # Filtered + sorted relation.
  def call
    by_status(filtered, params[:status]).reorder(sort_order)
  end

  # Tab counts. They respect search/priority/category but not the status filter,
  # so every tab shows how many items it would contain.
  def counts
    base = filtered
    {
      all: base.count,
      pending: base.pending.count,
      completed: base.completed.count,
      overdue: base.overdue.count
    }
  end

  private

  attr_reader :scope, :params

  def filtered
    relation = scope
    relation = relation.search(params[:q].strip) if params[:q].present?
    relation = relation.where(priority: params[:priority]) if Todo.priorities.key?(params[:priority])
    relation = relation.where(category_id: params[:category_id]) if params[:category_id].present?
    relation
  end

  def by_status(relation, status)
    case status
    when "pending" then relation.pending
    when "completed" then relation.completed
    when "overdue" then relation.overdue
    else relation
    end
  end

  def sort_order
    SORTS.fetch(params[:sort].to_s, SORTS["newest"])
  end
end
