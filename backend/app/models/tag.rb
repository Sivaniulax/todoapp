class Tag < ApplicationRecord
  belongs_to :user
  has_many :taggings, dependent: :destroy
  has_many :todos, through: :taggings, source: :taggable, source_type: "Todo"

  normalizes :name, with: ->(name) { name.squish.downcase }

  validates :name, presence: true, length: { maximum: 30 },
                   uniqueness: { scope: :user_id, case_sensitive: false }

  scope :alphabetical, -> { order(:name) }
  # Tags nothing points at any more; PurgeUnusedTagsJob clears them out.
  scope :unused, -> { where.missing(:taggings) }
end
