# Turns request params into a chain of scopes, so the controller stays thin:
#
#   TodosQuery.new(user.todos, status: "pending", q: "milk", sort: "due_date").call
class TodosQuery
  STATUSES = %w[all pending in_progress completed archived overdue].freeze

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
      in_progress: base.in_progress.count,
      completed: base.completed.count,
      archived: base.archived.count,
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
    relation = relation.joins(:tags).where(tags: { name: params[:tag].to_s.downcase }) if params[:tag].present?
    relation
  end

  def by_status(relation, status)
    case status
    when "overdue" then relation.overdue
    when *Todo.aasm.states.map { |state| state.name.to_s } then relation.where(status:)
    else relation
    end
  end

  def sort_order
    SORTS.fetch(params[:sort].to_s, SORTS["newest"])
  end
end
