class TodoResource
  include Alba::Resource

  attributes :id, :title, :description, :status, :completed_at, :due_date, :priority

  # Which transitions the client may offer right now.
  attribute :allowed_events do |todo|
    todo.aasm.events(permitted: true).map { |event| event.name.to_s }
  end

  attribute :overdue do |todo|
    todo.overdue?
  end

  attribute :trashed do |todo|
    todo.trashed?
  end

  attributes :discarded_at

  attribute :tags do |todo|
    todo.tags.map(&:name).sort
  end

  one :category, resource: CategoryResource

  # Send this back on update to get optimistic locking (409 on conflict).
  attributes :lock_version, :created_at, :updated_at
end
