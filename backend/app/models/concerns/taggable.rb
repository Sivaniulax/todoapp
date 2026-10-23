# Free-form tags through a polymorphic join table, so anything owned by a user
# can be tagged. Tags are created on demand and scoped to their owner.
#
#   todo.tag_names = "work, urgent"   # or [ "work", "urgent" ]
module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings

    after_save :sync_tags, if: -> { @pending_tag_names }
  end

  def tag_names
    tags.map(&:name)
  end

  def tag_names=(value)
    names = value.is_a?(String) ? value.split(",") : Array(value)
    @pending_tag_names = names.filter_map { |name| name.to_s.squish.presence&.downcase }.uniq
  end

  private

  def sync_tags
    self.tags = @pending_tag_names.map { |name| user.tags.find_or_create_by!(name:) }
    @pending_tag_names = nil
  end
end
