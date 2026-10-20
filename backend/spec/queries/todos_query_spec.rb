require "rails_helper"

RSpec.describe TodosQuery do
  let(:user) { create(:user) }
  let(:work) { create(:category, user:) }
  let!(:high) { create(:todo, user:, priority: :high, category: work, due_date: 3.days.from_now) }
  let!(:low) { create(:todo, user:, priority: :low, due_date: 1.day.from_now) }
  let!(:done) { create(:todo, :completed, user:, priority: :medium) }

  def run(params) = described_class.new(user.todos, params).call.to_a

  it "filters by status" do
    expect(run(status: "completed")).to eq([ done ])
    expect(run(status: "pending")).to contain_exactly(high, low)
  end

  it "filters by priority and category" do
    expect(run(priority: "high")).to eq([ high ])
    expect(run(category_id: work.id)).to eq([ high ])
    expect(run(priority: "bogus")).to contain_exactly(high, low, done)
  end

  it "sorts by due date with blanks last" do
    expect(run(sort: "due_date")).to eq([ low, high, done ])
  end

  it "sorts by priority" do
    expect(run(sort: "priority")).to eq([ high, done, low ])
  end

  it "counts each status for the current filters" do
    expect(described_class.new(user.todos, priority: "high").counts)
      .to eq(all: 1, pending: 1, completed: 0, overdue: 0)
  end
end
