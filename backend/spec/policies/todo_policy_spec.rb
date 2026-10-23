require "rails_helper"

RSpec.describe TodoPolicy do
  subject { described_class }

  let(:owner) { create(:user) }
  let(:someone_else) { create(:user) }
  let(:todo) { create(:todo, user: owner) }

  it "lets the owner change their todo" do
    expect(subject.new(owner, todo)).to be_update
    expect(subject.new(owner, todo)).to be_destroy
  end

  it "refuses someone else's todo" do
    expect(subject.new(someone_else, todo)).not_to be_update
    expect(subject.new(someone_else, todo)).not_to be_destroy
  end

  it "treats the status transitions as edits" do
    policy = subject.new(someone_else, todo)

    expect(policy).not_to be_complete
    expect(policy).not_to be_trash
    expect(policy).not_to be_restore
  end

  it "lets guests create todos - the limit is a validation, not a permission" do
    expect(subject.new(create(:user, :guest), Todo)).to be_create
  end

  describe "scope" do
    it "returns only the user's own todos" do
      mine = create(:todo, user: owner)
      create(:todo, user: someone_else)

      resolved = described_class::Scope.new(owner, Todo).resolve

      expect(resolved).to contain_exactly(mine, todo)
    end
  end
end
