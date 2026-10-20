require "rails_helper"

RSpec.describe CleanupExpiredGuestsJob do
  it "removes expired guests and their todos" do
    expired = create(:user, :guest, guest_expires_at: 1.hour.ago)
    create(:todo, user: expired)
    active = create(:user, :guest)

    expect(described_class.perform_now).to eq(1)
    expect(User.exists?(expired.id)).to be(false)
    expect(User.exists?(active.id)).to be(true)
    expect(Todo.where(user_id: expired.id)).to be_empty
  end
end
