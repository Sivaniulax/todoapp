require "rails_helper"

RSpec.describe UserPolicy do
  subject { described_class }

  let(:admin) { create(:user, :admin) }
  let(:member) { create(:user) }

  it "only lets admins list users" do
    expect(subject.new(admin, User)).to be_index
    expect(subject.new(member, User)).not_to be_index
  end

  it "lets a guest upgrade only their own account" do
    guest = create(:user, :guest)

    expect(subject.new(guest, guest)).to be_upgrade
    expect(subject.new(member, member)).not_to be_upgrade
    expect(subject.new(guest, member)).not_to be_upgrade
  end

  it "scopes everyone for an admin and just themselves for a member" do
    expect(described_class::Scope.new(admin, User).resolve).to include(admin, member)
    expect(described_class::Scope.new(member, User).resolve).to eq([ member ])
  end
end
