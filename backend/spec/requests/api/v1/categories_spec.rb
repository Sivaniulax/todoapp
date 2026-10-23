require "rails_helper"

RSpec.describe "Categories API" do
  let(:member) { create(:user) }

  before { sign_in member }

  it "lets members create, list, rename and delete categories" do
    post "/api/v1/categories", params: { category: { name: "Work", color: "#10B981" } },
                               as: :json
    expect(response).to have_http_status(:created)
    id = json.dig("category", "id")
    expect(json.dig("category", "color")).to eq("#10b981")

    patch "/api/v1/categories/#{id}", params: { category: { name: "Office" } }, as: :json
    expect(json.dig("category", "name")).to eq("Office")

    get "/api/v1/categories"
    expect(json["categories"].pluck("name")).to eq([ "Office" ])

    delete "/api/v1/categories/#{id}"
    expect(response).to have_http_status(:no_content)
  end

  it "keeps todos when their category is deleted" do
    category = create(:category, user: member)
    todo = create(:todo, user: member, category:)

    delete "/api/v1/categories/#{category.id}"

    expect(todo.reload.category).to be_nil
  end

  it "rejects duplicate names" do
    create(:category, user: member, name: "Work")
    post "/api/v1/categories", params: { category: { name: "work" } }, as: :json
    expect(response).to have_http_status(:unprocessable_content)
  end

  context "as a guest" do
    let(:guest) { create(:user, :guest) }

    before { sign_in guest }

    it "can list but not create" do
      get "/api/v1/categories"
      expect(response).to have_http_status(:ok)

      post "/api/v1/categories", params: { category: { name: "Work" } }, as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "nested todos" do
    let(:member) { create(:user) }

    it "creates a category together with its starter todos" do
      post "/api/v1/categories",
           params: { category: { name: "Onboarding", todos_attributes: [
             { title: "Read the docs", priority: "high" },
             { title: "Invite the team" }
           ] } },
           as: :json

      expect(response).to have_http_status(:created)

      category = member.categories.sole
      expect(category.todos.pluck(:title)).to contain_exactly("Read the docs", "Invite the team")
      # The nested todos inherit the category's owner.
      expect(category.todos.pluck(:user_id).uniq).to eq([ member.id ])
    end

    it "rolls the category back if one of its todos is invalid" do
      expect {
        post "/api/v1/categories",
             params: { category: { name: "Bad", todos_attributes: [ { title: "x" * 200 } ] } },
             as: :json
      }.not_to change(Category, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
