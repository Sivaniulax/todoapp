class UserSerializer < BaseSerializer
  def as_json(*)
    {
      id: record.id,
      name: record.name,
      email: record.guest? ? nil : record.email,
      role: record.role,
      todos_count: record.todos_count,
      guest_expires_at: record.guest_expires_at,
      created_at: record.created_at,
      limits: {
        max_todos: record.todo_limit,
        can_manage_categories: record.can_manage_categories?
      }
    }
  end
end
