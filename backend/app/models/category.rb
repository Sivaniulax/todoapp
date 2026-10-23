class Category < ApplicationRecord
  belongs_to :user
  has_many :todos, dependent: :nullify

  # So one request can create a category with a few starter todos.
  accepts_nested_attributes_for :todos, reject_if: :all_blank, limit: 20

  normalizes :name, with: ->(name) { name.squish }
  normalizes :color, with: ->(color) { color.strip.downcase }

  validates :name, presence: true, length: { maximum: 30 },
                   uniqueness: { scope: :user_id, case_sensitive: false }
  validates :color, hex_color: true

  scope :alphabetical, -> { order(Arel.sql("lower(name)")) }
end
