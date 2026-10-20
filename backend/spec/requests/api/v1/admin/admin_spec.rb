require "rails_helper"

RSpec.describe "Admin API" do
  let(:admin) { create(:user, :admin) }

  before do
    create(:user, :guest)
    member = create(:user)
    create(:todo, :completed, user: member)
    create(:todo, user: member)
  end

  it "returns stats for admins" do
    get "/api/v1/admin/stats", headers: auth_headers(admin)

    expect(response).to have_http_status(:ok)
    expect(json["users"]).to eq("total" => 3, "guests" => 1, "members" => 1, "admins" => 1)
    expect(json["todos"]).to include("total" => 2, "completed" => 1, "completion_rate" => 50.0)
  end

  it "lists users for admins" do
    get "/api/v1/admin/users", headers: auth_headers(admin)
    expect(json["users"].size).to eq(3)
    expect(json["meta"]["total_count"]).to eq(3)
  end

  it "is forbidden for members and guests" do
    get "/api/v1/admin/stats", headers: auth_headers(create(:user))
    expect(response).to have_http_status(:forbidden)

    get "/api/v1/admin/users", headers: auth_headers(create(:user, :guest))
    expect(response).to have_http_status(:forbidden)
  end
end
