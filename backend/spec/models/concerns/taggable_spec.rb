require "rails_helper"

RSpec.describe Taggable do
  let(:user) { create(:user) }
  let(:todo) { create(:todo, user:) }

  it "creates the user's tags on demand from an array" do
    todo.update!(tag_names: [ "Work", "urgent" ])

    expect(todo.reload.tag_names).to match_array(%w[work urgent])
    expect(user.tags.pluck(:name)).to match_array(%w[work urgent])
  end

  it "accepts a comma separated string and ignores blanks and duplicates" do
    todo.update!(tag_names: "work, , Work ,urgent")

    expect(todo.reload.tag_names).to match_array(%w[work urgent])
  end

  it "reuses an existing tag instead of duplicating it" do
    existing = create(:tag, user:, name: "work")

    expect { todo.update!(tag_names: [ "work" ]) }.not_to change(Tag, :count)
    expect(todo.reload.tags).to contain_exactly(existing)
  end

  it "replaces the previous set" do
    todo.update!(tag_names: [ "work", "urgent" ])
    todo.update!(tag_names: [ "home" ])

    expect(todo.reload.tag_names).to eq([ "home" ])
  end

  it "removes its taggings when the todo is destroyed" do
    todo.update!(tag_names: [ "work" ])

    expect { todo.destroy! }.to change(Tagging, :count).by(-1)
    expect(Tag.count).to eq(1) # the tag itself survives, PurgeUnusedTagsJob cleans it
  end
end
