class Todo < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :category, optional: true, counter_cache: true

  enum :priority, { low: 0, medium: 1, high: 2 }, default: :medium, validate: true

  normalizes :title, with: ->(title) { title.squish }

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 1_000 }
  validate :category_must_belong_to_user
  validate :guest_todo_limit, on: :create

  before_save :sync_completed_at

  # ---- Scopes: small, chainable query building blocks ----
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }
  scope :overdue, -> { pending.where(due_date: ...Date.current) }
  scope :due_today, -> { pending.where(due_date: Date.current) }
  scope :search, ->(term) {
    pattern = "%#{sanitize_sql_like(term)}%"
    where("todos.title ILIKE :pattern OR todos.description ILIKE :pattern", pattern:)
  }

  def overdue?
    !completed? && due_date.present? && due_date < Date.current
  end

  def toggle_completion!
    update!(completed: !completed)
  end

  private

  def sync_completed_at
    return unless will_save_change_to_completed?

    self.completed_at = completed? ? Time.current : nil
  end

  def category_must_belong_to_user
    return if category.nil? || category.user_id == user_id

    errors.add(:category, "must be one of your categories")
  end

  def guest_todo_limit
    return unless user&.guest?
    return if user.todos.count < user.todo_limit

    errors.add(:base, "Guests can only create #{user.todo_limit} todos. Create an account to add more.")
  end
end
