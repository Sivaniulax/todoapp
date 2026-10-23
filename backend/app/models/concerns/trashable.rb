# Soft delete. Trashed records stay in the table with a `discarded_at`
# timestamp so they can be restored, and are filtered out with `.kept`.
#
# Deliberately no `default_scope` - it is too easy to forget it is there.
module Trashable
  extend ActiveSupport::Concern

  included do
    scope :kept, -> { where(discarded_at: nil) }
    scope :trashed, -> { where.not(discarded_at: nil) }
  end

  def trashed?
    discarded_at.present?
  end

  def trash!
    update!(discarded_at: Time.current)
  end

  def restore!
    update!(discarded_at: nil)
  end
end
