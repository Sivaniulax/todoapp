require "rails_helper"

RSpec.describe Category do
  subject { build(:category) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:todos).dependent(:nullify) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(30) }

  it "is unique per user, ignoring case" do
    existing = create(:category, name: "Work")
    expect(build(:category, user: existing.user, name: "work")).not_to be_valid
    expect(build(:category, name: "work")).to be_valid
  end

  it "requires a hex color" do
    expect(build(:category, color: "red")).not_to be_valid
  end
end
