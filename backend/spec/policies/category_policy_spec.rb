require "rails_helper"

RSpec.describe CategoryPolicy do
  subject { described_class }

  let(:member) { create(:user) }
  let(:guest) { create(:user, :guest) }

  it "lets members manage their categories" do
    category = create(:category, user: member)

    expect(subject.new(member, Category)).to be_create
    expect(subject.new(member, category)).to be_update
  end

  it "lets guests list but not create" do
    expect(subject.new(guest, Category)).to be_index
    expect(subject.new(guest, Category)).not_to be_create
  end

  it "refuses a category belonging to another member" do
    expect(subject.new(member, create(:category))).not_to be_update
  end

  it "scopes to the user" do
    mine = create(:category, user: member)
    create(:category)

    expect(described_class::Scope.new(member, Category).resolve).to eq([ mine ])
  end
end
