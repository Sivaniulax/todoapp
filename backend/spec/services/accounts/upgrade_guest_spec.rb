require "rails_helper"

RSpec.describe Accounts::UpgradeGuest do
  let(:attributes) do
    { name: "Sivani", email: "sivani@example.com", password: "password123", password_confirmation: "password123" }
  end

  it "turns a guest into a member and keeps their todos" do
    guest = create(:user, :guest)
    create(:todo, user: guest)

    user = described_class.call(guest, attributes)

    expect(user).to be_member
    expect(user.guest_expires_at).to be_nil
    expect(user.email).to eq("sivani@example.com")
    expect(user.todos.count).to eq(1)
  end

  it "refuses non-guests" do
    expect { described_class.call(create(:user), attributes) }.to raise_error(ApiError::Forbidden)
  end

  it "raises on invalid data" do
    expect { described_class.call(create(:user, :guest), attributes.merge(password_confirmation: "nope")) }
      .to raise_error(ActiveRecord::RecordInvalid)
  end
end
