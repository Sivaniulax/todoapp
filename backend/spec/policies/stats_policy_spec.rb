require "rails_helper"

RSpec.describe StatsPolicy do
  it "is admin only" do
    expect(described_class.new(create(:user, :admin), :stats)).to be_show
    expect(described_class.new(create(:user), :stats)).not_to be_show
    expect(described_class.new(create(:user, :guest), :stats)).not_to be_show
  end
end
