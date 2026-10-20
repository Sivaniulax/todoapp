require "rails_helper"

RSpec.describe "Categories API" do
  let(:member) { create(:user) }

  it "lets members create, list, rename and delete categories" do
    post "/api/v1/categories", params: { category: { name: "Work", color: "#10B981" } },
                               headers: auth_headers(member), as: :json
    expect(response).to have_http_status(:created)
    id = json.dig("category", "id")
    expect(json.dig("category", "color")).to eq("#10b981")

    patch "/api/v1/categories/#{id}", params: { category: { name: "Office" } }, headers: auth_headers(member), as: :json
    expect(json.dig("category", "name")).to eq("Office")

    get "/api/v1/categories", headers: auth_headers(member)
    expect(json["categories"].pluck("name")).to eq([ "Office" ])

    delete "/api/v1/categories/#{id}", headers: auth_headers(member)
    expect(response).to have_http_status(:no_content)
  end

  it "keeps todos when their category is deleted" do
    category = create(:category, user: member)
    todo = create(:todo, user: member, category:)

    delete "/api/v1/categories/#{category.id}", headers: auth_headers(member)

    expect(todo.reload.category).to be_nil
  end

  it "rejects duplicate names" do
    create(:category, user: member, name: "Work")
    post "/api/v1/categories", params: { category: { name: "work" } }, headers: auth_headers(member), as: :json
    expect(response).to have_http_status(:unprocessable_content)
  end

  context "as a guest" do
    let(:guest) { create(:user, :guest) }

    it "can list but not create" do
      get "/api/v1/categories", headers: auth_headers(guest)
      expect(response).to have_http_status(:ok)

      post "/api/v1/categories", params: { category: { name: "Work" } }, headers: auth_headers(guest), as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end
end
