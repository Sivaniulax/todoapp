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
    it "covers the whole workspace, not just the signed-in member" do
      colleague = create(:user, workspace: owner.workspace)
      mine = create(:todo, user: owner)
      theirs = create(:todo, user: colleague)
      create(:todo, user: someone_else) # another workspace entirely

      resolved = ActsAsTenant.with_tenant(owner.workspace) do
        described_class::Scope.new(owner, Todo).resolve.to_a
      end

      expect(resolved).to contain_exactly(mine, theirs)
    end
  end
end
