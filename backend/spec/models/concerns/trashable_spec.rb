require "rails_helper"

# Trashable is included by Todo; exercising it through Todo keeps the
# test honest about how it is actually used.
RSpec.describe Trashable do
  let(:todo) { create(:todo) }

  it "starts out kept" do
    expect(todo).not_to be_trashed
    expect(Todo.kept).to include(todo)
    expect(Todo.trashed).not_to include(todo)
  end

  it "trashes without deleting the row" do
    freeze_time do
      todo.trash!

      expect(todo).to be_trashed
      expect(todo.discarded_at).to eq(Time.current)
      expect(Todo.exists?(todo.id)).to be(true)
    end
  end

  it "moves between the kept and trashed scopes" do
    todo.trash!
    expect(Todo.trashed).to contain_exactly(todo)
    expect(Todo.kept).to be_empty

    todo.restore!
    expect(todo).not_to be_trashed
    expect(Todo.kept).to contain_exactly(todo)
  end
end
