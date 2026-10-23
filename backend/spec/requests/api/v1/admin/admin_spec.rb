require "rails_helper"

RSpec.describe "Admin API" do
  let(:admin) { create(:user, :admin) }

  before do
    create(:user, :guest)
    member = create(:user)
    create(:todo, :completed, user: member)
    create(:todo, user: member)

    sign_in admin
  end

  it "returns stats for admins" do
    get "/api/v1/admin/stats"

    expect(response).to have_http_status(:ok)
    expect(json["users"]).to eq("total" => 3, "guests" => 1, "members" => 1, "admins" => 1)
    expect(json["todos"]).to include("total" => 2, "completed" => 1, "completion_rate" => 50.0)
  end

  it "lists users for admins" do
    get "/api/v1/admin/users"
    expect(json["users"].size).to eq(3)
    expect(json["meta"]["total_count"]).to eq(3)
  end

  it "is forbidden for members and guests" do
    sign_in create(:user)
    get "/api/v1/admin/stats"
    expect(response).to have_http_status(:forbidden)

    sign_in create(:user, :guest)
    get "/api/v1/admin/users"
    expect(response).to have_http_status(:forbidden)
  end

  # The outer `before` block already creates two todos, so these assertions
  # are relative to whatever the baseline happens to be.
  describe "stats caching" do
    let(:cache) { ActiveSupport::Cache::MemoryStore.new }

    before { allow(Rails).to receive(:cache).and_return(cache) }

    it "serves repeat requests from the cache until it is cleared" do
      get "/api/v1/admin/stats"
      baseline = json.dig("todos", "total")

      create(:todo)
      get "/api/v1/admin/stats"
      expect(json.dig("todos", "total")).to eq(baseline) # still the cached payload

      cache.clear
      get "/api/v1/admin/stats"
      expect(json.dig("todos", "total")).to eq(baseline + 1)
    end

    it "counts only kept todos" do
      get "/api/v1/admin/stats"
      baseline = json.dig("todos", "total")

      create(:todo).trash!
      cache.clear
      get "/api/v1/admin/stats"

      expect(json.dig("todos", "total")).to eq(baseline)
      expect(json.dig("todos", "trashed")).to eq(1)
    end
  end
end
