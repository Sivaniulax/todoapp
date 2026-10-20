require "rails_helper"

RSpec.describe "Todos API" do
  let(:user) { create(:user) }
  let(:headers) { auth_headers(user) }

  describe "GET /api/v1/todos" do
    it "only returns the current user's todos" do
      mine = create(:todo, user:)
      create(:todo) # someone else's

      get "/api/v1/todos", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json["todos"].pluck("id")).to eq([ mine.id ])
    end

    it "filters, searches and returns counts" do
      create(:todo, user:, title: "Buy milk", priority: :high)
      create(:todo, :completed, user:, title: "Buy bread")
      create(:todo, user:, title: "Gym")

      get "/api/v1/todos", params: { q: "buy", status: "pending" }, headers: headers

      expect(json["todos"].pluck("title")).to eq([ "Buy milk" ])
      expect(json.dig("meta", "counts")).to eq("all" => 2, "pending" => 1, "completed" => 1, "overdue" => 0)
    end

    it "paginates" do
      create_list(:todo, 12, user:)

      get "/api/v1/todos", params: { page: 2, per_page: 5 }, headers: headers

      expect(json["todos"].size).to eq(5)
      expect(json["meta"]).to include("page" => 2, "per_page" => 5, "total_count" => 12, "total_pages" => 3)
    end
  end

  describe "POST /api/v1/todos" do
    it "creates a todo" do
      category = create(:category, user:)
      params = { todo: { title: "Ship it", priority: "high", due_date: "2030-01-01", category_id: category.id } }

      expect { post "/api/v1/todos", params:, headers:, as: :json }.to change(user.todos, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["todo"]).to include("title" => "Ship it", "priority" => "high", "due_date" => "2030-01-01")
      expect(json.dig("todo", "category", "name")).to eq(category.name)
    end

    it "returns 422 for invalid data" do
      post "/api/v1/todos", params: { todo: { title: "" } }, headers:, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json.dig("details", "title")).to include("can't be blank")
    end

    it "enforces the guest limit" do
      guest = create(:user, :guest)
      create_list(:todo, User::GUEST_TODO_LIMIT, user: guest)

      post "/api/v1/todos", params: { todo: { title: "one more" } }, headers: auth_headers(guest), as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json.dig("details", "base").first).to match(/Guests can only create/)
    end
  end

  describe "member actions" do
    let!(:todo) { create(:todo, user:, title: "Old") }

    it "updates" do
      patch "/api/v1/todos/#{todo.id}", params: { todo: { title: "New" } }, headers:, as: :json
      expect(json.dig("todo", "title")).to eq("New")
    end

    it "toggles" do
      patch "/api/v1/todos/#{todo.id}/toggle", headers:, as: :json
      expect(json.dig("todo", "completed")).to be(true)
      expect(json.dig("todo", "completed_at")).to be_present
    end

    it "deletes" do
      delete "/api/v1/todos/#{todo.id}", headers: headers
      expect(response).to have_http_status(:no_content)
      expect(Todo.exists?(todo.id)).to be(false)
    end

    it "returns 404 for another user's todo" do
      other = create(:todo)
      patch "/api/v1/todos/#{other.id}", params: { todo: { title: "Hacked" } }, headers:, as: :json

      expect(response).to have_http_status(:not_found)
      expect(other.reload.title).not_to eq("Hacked")
    end
  end

  describe "DELETE /api/v1/todos/clear_completed" do
    it "deletes only completed todos" do
      create_list(:todo, 2, :completed, user:)
      pending = create(:todo, user:)

      delete "/api/v1/todos/clear_completed", headers: headers

      expect(json["deleted_count"]).to eq(2)
      expect(user.todos.reload).to eq([ pending ])
      expect(user.reload.todos_count).to eq(1)
    end
  end
end
