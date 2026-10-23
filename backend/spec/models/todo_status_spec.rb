require "rails_helper"

RSpec.describe Todo, "status" do
  subject(:todo) { create(:todo) }

  it "starts out pending" do
    expect(todo).to be_pending
    expect(todo).to be_outstanding
  end

  it "runs pending -> in progress -> completed -> archived" do
    expect(todo.start!).to be(true)
    expect(todo).to be_in_progress

    expect(todo.complete!).to be(true)
    expect(todo.completed_at).to be_present

    expect(todo.archive!).to be(true)
    expect(todo).to be_archived
    expect(todo).not_to be_outstanding
  end

  it "will not archive a todo that was never completed" do
    expect(todo.archive!).to be(false)
    expect(todo.reload).to be_pending
  end

  it "clears completed_at when reopened" do
    todo.complete!
    todo.reopen!

    expect(todo).to be_pending
    expect(todo.completed_at).to be_nil
  end

  it "can pick a completed todo back up" do
    todo.complete!

    expect(todo.start!).to be(true)
    expect(todo).to be_in_progress
  end

  it "reports which events are allowed from here" do
    expect(todo.aasm.events(permitted: true).map(&:name)).to contain_exactly(:start, :complete)
  end

  describe "an overdue todo" do
    it "stops counting as overdue once it is done" do
      todo = create(:todo, due_date: 2.days.ago.to_date)
      expect(todo).to be_overdue

      todo.complete!
      expect(todo).not_to be_overdue
    end
  end

  describe "scopes" do
    it "separates outstanding work from the rest" do
      pending_todo = create(:todo)
      started = create(:todo, :in_progress)
      done = create(:todo, :completed)
      filed = create(:todo, :archived)

      expect(described_class.outstanding).to contain_exactly(pending_todo, started)
      expect(described_class.completed).to contain_exactly(done)
      expect(described_class.archived).to contain_exactly(filed)
    end
  end
end
