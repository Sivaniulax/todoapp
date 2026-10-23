require "rails_helper"

RSpec.describe Tag do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:taggings).dependent(:destroy) }
  it { is_expected.to have_many(:todos).through(:taggings) }

  it "downcases and squishes the name" do
    expect(create(:tag, name: "  Deep   Work ").name).to eq("deep work")
  end

  it "is unique per user, ignoring case" do
    user = create(:user)
    create(:tag, user:, name: "work")

    expect(build(:tag, user:, name: "WORK")).not_to be_valid
    expect(build(:tag, user: create(:user), name: "WORK")).to be_valid
  end

  describe ".unused" do
    it "finds only tags nothing points at" do
      used = create(:tag)
      orphan = create(:tag)
      create(:todo, user: used.user).tags << used

      expect(described_class.unused).to contain_exactly(orphan)
    end
  end
end
