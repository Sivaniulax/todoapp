require "rails_helper"

RSpec.describe PurgeUnusedTagsJob do
  it "deletes only the tags nothing is tagged with" do
    used = create(:tag)
    create(:todo, user: used.user).tags << used
    create(:tag)
    create(:tag)

    expect { described_class.perform_now }.to change(Tag, :count).from(3).to(1)
    expect(Tag.all).to contain_exactly(used)
  end

  it "returns the number removed" do
    create(:tag)
    expect(described_class.perform_now).to eq(1)
  end
end
