# Tags are created on demand, so untagging the last todo leaves orphans behind.
# Scheduled weekly from config/recurring.yml.
class PurgeUnusedTagsJob < ApplicationJob
  queue_as :default

  def perform
    count = Tag.unused.delete_all
    Rails.logger.info("[PurgeUnusedTagsJob] removed #{count} unused tag(s)")
    count
  end
end
