class Todo < ApplicationRecord
  include AASM
  include Trashable
  include Taggable

  acts_as_tenant :workspace

  # Keep an audit trail. lock_version and updated_at move on every save and
  # say nothing, so they are left out.
  has_paper_trail ignore: %i[lock_version updated_at]

  belongs_to :user, counter_cache: true
  belongs_to :category, optional: true, counter_cache: true

  enum :priority, { low: 0, medium: 1, high: 2 }, default: :medium, validate: true

  normalizes :title, with: ->(title) { title.squish }

  # A todo built through Category's nested attributes has no user of its own yet.
  before_validation :inherit_user_from_category
  # acts_as_tenant fills this in during a request; outside one (jobs, seeds,
  # the console) take it from whoever owns the todo.
  before_validation :inherit_workspace

  validates :title, presence: true, length: { maximum: 120 }
  validates :description, length: { maximum: 1_000 }
  validate :category_must_belong_to_user
  validate :guest_todo_limit, on: :create

  before_save :sync_completed_at

  # AASM gives us the predicates (completed?), a scope per state, and
  # may_complete? for asking before trying. Bang events return false on a
  # transition that is not allowed rather than raising.
  aasm column: :status, whiny_transitions: false do
    state :pending, initial: true
    state :in_progress
    state :completed
    state :archived

    event :start do
      transitions from: %i[pending completed], to: :in_progress
    end

    event :complete do
      transitions from: %i[pending in_progress], to: :completed
    end

    event :reopen do
      transitions from: %i[in_progress completed archived], to: :pending
    end

    # Only a finished todo gets filed away.
    event :archive do
      transitions from: :completed, to: :archived
    end
  end

  scope :outstanding, -> { where(status: %w[pending in_progress]) }
  scope :overdue, -> { outstanding.where(due_date: ...Date.current) }
  scope :due_today, -> { outstanding.where(due_date: Date.current) }
  scope :search, ->(term) {
    pattern = "%#{sanitize_sql_like(term)}%"
    where("todos.title ILIKE :pattern OR todos.description ILIKE :pattern", pattern:)
  }

  def outstanding?
    pending? || in_progress?
  end

  def overdue?
    outstanding? && due_date.present? && due_date < Date.current
  end

  private

  def inherit_user_from_category
    self.user ||= category&.user
  end

  def inherit_workspace
    self.workspace ||= user&.workspace || category&.workspace
  end

  def sync_completed_at
    return unless will_save_change_to_status?

    self.completed_at = completed? ? Time.current : nil
  end

  def category_must_belong_to_user
    return if category.nil? || category.workspace_id == workspace_id

    errors.add(:category, :not_your_category)
  end

  def guest_todo_limit
    return unless user&.guest?
    return if user.todos.kept.count < user.todo_limit

    errors.add(:base, :guest_todo_limit, limit: user.todo_limit)
  end
end
