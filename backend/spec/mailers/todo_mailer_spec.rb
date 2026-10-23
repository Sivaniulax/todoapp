require "rails_helper"

RSpec.describe TodoMailer do
  let(:user) { create(:user, name: "Ada", email: "ada@example.com") }

  describe "#daily_digest" do
    it "lists the todos that are due today" do
      create(:todo, user:, title: "Ship the digest", due_date: Date.current, priority: :high)
      create(:todo, user:, title: "Not due yet", due_date: 3.days.from_now.to_date)

      mail = described_class.daily_digest(user)

      expect(mail.subject).to eq("You have 1 todo due today")
      expect(mail.text_part.body.to_s).to include("Ship the digest")
      expect(mail.text_part.body.to_s).not_to include("Not due yet")
    end

    it "pluralises the subject" do
      create_list(:todo, 2, user:, due_date: Date.current)

      expect(described_class.daily_digest(user).subject).to eq("You have 2 todos due today")
    end

    it "ignores completed and trashed todos" do
      create(:todo, :completed, user:, due_date: Date.current)
      create(:todo, user:, due_date: Date.current).trash!

      expect(described_class.daily_digest(user).message).to be_a(ActionMailer::Base::NullMail)
    end

    it "sends nothing when there is nothing due" do
      expect(described_class.daily_digest(user).message).to be_a(ActionMailer::Base::NullMail)
    end
  end
end
