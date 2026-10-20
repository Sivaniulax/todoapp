class ApplicationJob < ActiveJob::Base
  # Retry jobs that hit a deadlock.
  retry_on ActiveRecord::Deadlocked
end
