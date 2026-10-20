class Category < ApplicationRecord
  COLOR_FORMAT = /\A#\h{6}\z/

  belongs_to :user
  has_many :todos, dependent: :nullify

  normalizes :name, with: ->(name) { name.squish }
  normalizes :color, with: ->(color) { color.strip.downcase }

  validates :name, presence: true, length: { maximum: 30 },
                   uniqueness: { scope: :user_id, case_sensitive: false }
  validates :color, format: { with: COLOR_FORMAT, message: "must be a hex color like #6366f1" }

  scope :alphabetical, -> { order(Arel.sql("lower(name)")) }
end
