class User < ApplicationRecord
  GUEST_TTL = 24.hours
  GUEST_TODO_LIMIT = 10

  has_secure_password

  # enum gives us user.guest?, user.admin!, User.member (scope), etc.
  # `validate: true` turns an unknown role into a validation error instead of an ArgumentError.
  enum :role, { guest: 0, member: 1, admin: 2 }, default: :member, validate: true

  has_many :todos, dependent: :delete_all
  has_many :categories, dependent: :delete_all

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8, maximum: 72 }, allow_nil: true
  validates :guest_expires_at, presence: true, if: :guest?

  scope :expired_guests, -> { guest.where(guest_expires_at: ...Time.current) }
  scope :newest_first, -> { order(created_at: :desc) }

  def self.create_guest!
    create!(
      name: "Guest",
      email: "guest-#{SecureRandom.hex(8)}@guest.todoapp.local",
      password: SecureRandom.base58(32),
      role: :guest,
      guest_expires_at: GUEST_TTL.from_now
    )
  end

  def guest_expired?
    guest? && guest_expires_at.past?
  end

  def todo_limit
    GUEST_TODO_LIMIT if guest?
  end

  def can_manage_categories?
    member? || admin?
  end
end
