require "rails_helper"

RSpec.describe Todo do
  subject { build(:todo) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:category).optional }
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_length_of(:title).is_at_most(120) }

  it "rejects an unknown priority instead of raising" do
    todo = build(:todo, priority: "urgent")
    expect(todo).not_to be_valid
    expect(todo.errors[:priority]).to be_present
  end

  it "does not allow another user's category" do
    todo = build(:todo, category: create(:category))
    expect(todo).not_to be_valid
    expect(todo.errors[:category]).to include("must be one of your categories")
  end

  it "sets and clears completed_at" do
    todo = create(:todo)
    todo.toggle_completion!
    expect(todo.completed_at).to be_present
    todo.toggle_completion!
    expect(todo.completed_at).to be_nil
  end

  it "keeps the user's todos_count up to date" do
    user = create(:user)
    create_list(:todo, 2, user:)
    expect(user.reload.todos_count).to eq(2)
  end

  describe "guest limit" do
    it "stops guests at the limit" do
      guest = create(:user, :guest)
      create_list(:todo, User::GUEST_TODO_LIMIT, user: guest)

      todo = build(:todo, user: guest)
      expect(todo).not_to be_valid
      expect(todo.errors[:base].first).to match(/Guests can only create/)
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }
    let!(:done) { create(:todo, :completed, user:, title: "Buy milk") }
    let!(:late) { create(:todo, :overdue, user:, title: "Pay rent", description: "before the 5th") }
    let!(:today) { create(:todo, user:, due_date: Date.current) }

    it { expect(described_class.completed).to contain_exactly(done) }
    it { expect(described_class.pending).to contain_exactly(late, today) }
    it { expect(described_class.overdue).to contain_exactly(late) }
    it { expect(described_class.due_today).to contain_exactly(today) }
    it { expect(described_class.search("MILK")).to contain_exactly(done) }
    it { expect(described_class.search("5th")).to contain_exactly(late) }
    it { expect(described_class.search("100%")).to be_empty }

    it "knows when it is overdue" do
      expect(late).to be_overdue
      expect(today).not_to be_overdue
    end
  end
end
