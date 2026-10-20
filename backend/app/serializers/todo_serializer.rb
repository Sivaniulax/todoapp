class TodoSerializer < BaseSerializer
  def as_json(*)
    {
      id: record.id,
      title: record.title,
      description: record.description,
      completed: record.completed,
      completed_at: record.completed_at,
      due_date: record.due_date,
      priority: record.priority,
      overdue: record.overdue?,
      category: category_json,
      created_at: record.created_at,
      updated_at: record.updated_at
    }
  end

  private

  def category_json
    return unless record.category

    { id: record.category.id, name: record.category.name, color: record.category.color }
  end
end
