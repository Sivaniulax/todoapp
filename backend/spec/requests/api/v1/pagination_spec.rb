require "rails_helper"

RSpec.describe "Pagination" do
  let(:user) { create(:user) }

  before { sign_in user }

  it "reports the page, the size and the totals" do
    create_list(:todo, 12, user:)

    get "/api/v1/todos", params: { page: 2, per_page: 5 }

    expect(json["todos"].size).to eq(5)
    expect(json["meta"]).to include("page" => 2, "per_page" => 5, "total_count" => 12, "total_pages" => 3)
  end

  it "returns an empty page rather than an error past the end" do
    create_list(:todo, 3, user:)

    get "/api/v1/todos", params: { page: 99 }

    expect(response).to have_http_status(:ok)
    expect(json["todos"]).to be_empty
    expect(json.dig("meta", "total_count")).to eq(3)
  end

  it "caps how much a client can ask for in one go" do
    get "/api/v1/todos", params: { per_page: 5_000 }

    expect(json.dig("meta", "per_page")).to eq(Pagination::MAX_PER_PAGE)
  end

  it "falls back to the default size for nonsense" do
    get "/api/v1/todos", params: { per_page: "-4" }

    expect(json.dig("meta", "per_page")).to eq(Pagination::DEFAULT_PER_PAGE)
  end
end
