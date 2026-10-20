require "rails_helper"

RSpec.describe User do
  subject { build(:user) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it "requires 8+ character passwords" do
      expect(build(:user, password: "short")).not_to be_valid
    end
    it { is_expected.to have_many(:todos).dependent(:delete_all) }
    it { is_expected.to have_many(:categories).dependent(:delete_all) }

    it "rejects malformed emails" do
      expect(build(:user, email: "not-an-email")).not_to be_valid
    end
  end

  it "normalizes email" do
    expect(create(:user, email: "  Sivani@Example.COM ").email).to eq("sivani@example.com")
  end

  describe ".create_guest!" do
    it "creates a guest that expires in 24 hours" do
      freeze_time do
        guest = described_class.create_guest!
        expect(guest).to be_guest
        expect(guest.guest_expires_at).to eq(24.hours.from_now)
        expect(guest.todo_limit).to eq(User::GUEST_TODO_LIMIT)
        expect(guest.can_manage_categories?).to be(false)
      end
    end
  end

  describe ".expired_guests" do
    it "returns only guests past their expiry" do
      expired = create(:user, :guest, guest_expires_at: 1.minute.ago)
      create(:user, :guest)
      create(:user)

      expect(described_class.expired_guests).to contain_exactly(expired)
    end
  end
end
