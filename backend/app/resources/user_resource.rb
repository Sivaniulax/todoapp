class UserResource
  include Alba::Resource

  attributes :id, :name

  # Guests get a throwaway address; it never goes back over the wire.
  attribute :email do |user|
    user.email unless user.guest?
  end

  attributes :role, :todos_count, :guest_expires_at, :created_at

  attribute :workspace do |user|
    { id: user.workspace_id, name: user.workspace.name }
  end

  attribute :limits do |user|
    { max_todos: user.todo_limit, can_manage_categories: user.can_manage_categories? }
  end
end
