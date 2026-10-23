require "rails_helper"

RSpec.describe Todos::BulkCreateForm do
  let(:user) { create(:user) }

  def form(attributes) = described_class.new(user, attributes)

  it "creates one todo per line and ignores blanks" do
    subject = form(titles_text: "Buy milk\n\n  Walk the dog  \n")

    expect { expect(subject.save).to be(true) }.to change(user.todos, :count).by(2)
    expect(subject.todos.map(&:title)).to eq([ "Buy milk", "Walk the dog" ])
  end

  it "applies the shared priority, category and due date" do
    category = create(:category, user:)
    subject = form(titles_text: "One\nTwo", priority: "high",
                   category_id: category.id, due_date: "2026-12-01")

    expect(subject.save).to be(true)
    expect(subject.todos).to all(have_attributes(priority: "high", category:, due_date: Date.new(2026, 12, 1)))
  end

  it "requires some text" do
    subject = form(titles_text: "   ")

    expect(subject.save).to be(false)
    expect(subject.errors[:titles_text]).to be_present
  end

  it "rejects an unknown priority" do
    subject = form(titles_text: "One", priority: "urgent")

    expect(subject.save).to be(false)
    expect(subject.errors[:priority]).to be_present
  end

  it "refuses more than #{described_class::MAX_TODOS} at once" do
    subject = form(titles_text: Array.new(described_class::MAX_TODOS + 1) { |i| "Todo #{i}" }.join("\n"))

    expect(subject.save).to be(false)
    expect(subject.errors[:titles_text].first).to match(/cannot contain more than/)
  end

  it "rolls the whole batch back when one line is invalid" do
    subject = form(titles_text: "Fine\n#{'x' * 200}\nAlso fine")

    expect { expect(subject.save).to be(false) }.not_to change(Todo, :count)
    expect(subject.errors[:title]).to be_present
    expect(subject.todos).to be_empty
  end
end
