class Todo < ApplicationRecord
  include Trashable
  include Taggable

  belongs_to :user, counter_cache: true
  belongs_to :category, optional: true, counter_cache: true

  enum :priority, { low: 0, medium: 1, high: 2 }, default: :medium, validate: true

  normalizes :title, with: ->(title) { title.squish }

  # A todo built through Category's nested attributes has no user of its own yet.
  before_validation :inherit_user_from_category

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 1_000 }
  validate :category_must_belong_to_user
  validate :guest_todo_limit, on: :create

  before_save :sync_completed_at

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

  def inherit_user_from_category
    self.user ||= category&.user
  end

  def sync_completed_at
    return unless will_save_change_to_completed?

    self.completed_at = completed? ? Time.current : nil
  end

  def category_must_belong_to_user
    return if category.nil? || category.user_id == user_id

    errors.add(:category, :not_your_category)
  end

  def guest_todo_limit
    return unless user&.guest?
    return if user.todos.kept.count < user.todo_limit

    errors.add(:base, :guest_todo_limit, limit: user.todo_limit)
  end
end
