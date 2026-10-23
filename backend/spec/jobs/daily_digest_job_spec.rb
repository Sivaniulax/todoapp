require "rails_helper"

RSpec.describe DailyDigestJob do
  it "queues a digest for each member who has something due today" do
    due = create(:user)
    create(:todo, user: due, due_date: Date.current)
    create(:user) # nothing due

    expect { described_class.perform_now }
      .to have_enqueued_mail(TodoMailer, :daily_digest).once.with(due)
  end

  it "skips guests, who have no real address" do
    guest = User.create_guest!
    create(:todo, user: guest, due_date: Date.current)

    expect { described_class.perform_now }.not_to have_enqueued_mail(TodoMailer, :daily_digest)
  end

  it "ignores trashed todos" do
    user = create(:user)
    create(:todo, user:, due_date: Date.current).trash!

    expect { described_class.perform_now }.not_to have_enqueued_mail(TodoMailer, :daily_digest)
  end

  it "returns how many digests it queued" do
    user = create(:user)
    create(:todo, user:, due_date: Date.current)

    expect(described_class.perform_now).to eq(1)
  end
end
