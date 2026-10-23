class Tag < ApplicationRecord
  acts_as_tenant :workspace

  belongs_to :user
  has_many :taggings, dependent: :destroy
  has_many :todos, through: :taggings, source: :taggable, source_type: "Todo"

  normalizes :name, with: ->(name) { name.squish.downcase }

  before_validation { self.workspace ||= user&.workspace }

  validates :name, presence: true, length: { maximum: 30 },
                   uniqueness: { scope: :workspace_id, case_sensitive: false }

  scope :alphabetical, -> { order(:name) }
  # Tags nothing points at any more; PurgeUnusedTagsJob clears them out.
  scope :unused, -> { where.missing(:taggings) }
end
