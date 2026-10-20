class CategorySerializer < BaseSerializer
  def as_json(*)
    {
      id: record.id,
      name: record.name,
      color: record.color,
      todos_count: record.todos_count
    }
  end
end
