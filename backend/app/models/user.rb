class User < ApplicationRecord
  GUEST_TTL = 24.hours
  GUEST_TODO_LIMIT = 10

  # database_authenticatable gives us encrypted_password and valid_password?,
  # validatable the email/password validations, timeoutable the 24h expiry.
  devise :database_authenticatable, :validatable, :timeoutable

  # `validate: true` turns an unknown role into a validation error rather than
  # an ArgumentError.
  enum :role, { guest: 0, member: 1, admin: 2 }, default: :member, validate: true

  has_many :todos, dependent: :delete_all
  has_many :categories, dependent: :delete_all
  has_many :tags, dependent: :delete_all

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :name, with: ->(name) { name.squish }

  # Devise's :validatable covers email presence, format and uniqueness, and
  # the password length and confirmation.
  validates :name, presence: true, length: { maximum: 50 }
  validates :guest_expires_at, presence: true, if: :guest?

  # Guests get a throwaway address, so they are never emailed.
  after_create_commit :send_welcome_email, unless: :guest?

  scope :expired_guests, -> { guest.where(guest_expires_at: ...Time.current) }
  scope :newest_first, -> { order(created_at: :desc) }
  # Everyone with a real email address (i.e. not a throwaway guest).
  scope :registered, -> { where.not(role: :guest) }

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

  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end
end
