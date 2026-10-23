require "rails_helper"

RSpec.describe "Todos API" do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /api/v1/todos" do
    it "only returns the current user's todos" do
      mine = create(:todo, user:)
      create(:todo) # someone else's

      get "/api/v1/todos"

      expect(response).to have_http_status(:ok)
      expect(json["todos"].pluck("id")).to eq([ mine.id ])
    end

    it "filters, searches and returns counts" do
      create(:todo, user:, title: "Buy milk", priority: :high)
      create(:todo, :completed, user:, title: "Buy bread")
      create(:todo, user:, title: "Gym")

      get "/api/v1/todos", params: { q: "buy", status: "pending" }

      expect(json["todos"].pluck("title")).to eq([ "Buy milk" ])
      expect(json.dig("meta", "counts"))
        .to eq("all" => 2, "pending" => 1, "in_progress" => 0, "completed" => 1, "archived" => 0, "overdue" => 0)
    end

    it "paginates" do
      create_list(:todo, 12, user:)

      get "/api/v1/todos", params: { page: 2, per_page: 5 }

      expect(json["todos"].size).to eq(5)
      expect(json["meta"]).to include("page" => 2, "per_page" => 5, "total_count" => 12, "total_pages" => 3)
    end
  end

  describe "POST /api/v1/todos" do
    it "creates a todo" do
      category = create(:category, user:)
      params = { todo: { title: "Ship it", priority: "high", due_date: "2030-01-01", category_id: category.id } }

      expect { post "/api/v1/todos", params:, as: :json }.to change(user.todos, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json["todo"]).to include("title" => "Ship it", "priority" => "high", "due_date" => "2030-01-01")
      expect(json.dig("todo", "category", "name")).to eq(category.name)
    end

    it "returns 422 for invalid data" do
      post "/api/v1/todos", params: { todo: { title: "" } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json.dig("details", "title")).to include("can't be blank")
    end

    it "enforces the guest limit" do
      guest = create(:user, :guest)
      create_list(:todo, User::GUEST_TODO_LIMIT, user: guest)
      sign_in guest

      post "/api/v1/todos", params: { todo: { title: "one more" } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json.dig("details", "base").first).to match(/Guests can only create/)
    end
  end

  describe "member actions" do
    let!(:todo) { create(:todo, user:, title: "Old") }

    it "updates" do
      patch "/api/v1/todos/#{todo.id}", params: { todo: { title: "New" } }, as: :json
      expect(json.dig("todo", "title")).to eq("New")
    end

    it "walks the status through its transitions" do
      patch "/api/v1/todos/#{todo.id}/start", as: :json
      expect(json.dig("todo", "status")).to eq("in_progress")

      patch "/api/v1/todos/#{todo.id}/complete", as: :json
      expect(json.dig("todo", "status")).to eq("completed")
      expect(json.dig("todo", "completed_at")).to be_present

      patch "/api/v1/todos/#{todo.id}/archive", as: :json
      expect(json.dig("todo", "status")).to eq("archived")
    end

    it "refuses a transition the state machine does not allow" do
      patch "/api/v1/todos/#{todo.id}/archive", as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["error"]).to match(/cannot archive/i)
      expect(todo.reload).to be_pending
    end

    it "lists the events the client may offer" do
      patch "/api/v1/todos/#{todo.id}/complete", as: :json

      expect(json.dig("todo", "allowed_events")).to contain_exactly("start", "reopen", "archive")
    end

    it "deletes" do
      delete "/api/v1/todos/#{todo.id}"
      expect(response).to have_http_status(:no_content)
      expect(Todo.exists?(todo.id)).to be(false)
    end

    it "returns 404 for another user's todo" do
      other = create(:todo)
      patch "/api/v1/todos/#{other.id}", params: { todo: { title: "Hacked" } }, as: :json

      expect(response).to have_http_status(:not_found)
      expect(other.reload.title).not_to eq("Hacked")
    end
  end

  describe "DELETE /api/v1/todos/clear_completed" do
    it "deletes only completed todos" do
      create_list(:todo, 2, :completed, user:)
      pending = create(:todo, user:)

      delete "/api/v1/todos/clear_completed"

      expect(json["deleted_count"]).to eq(2)
      expect(user.todos.reload).to eq([ pending ])
      expect(user.reload.todos_count).to eq(1)
    end
  end

  describe "soft delete" do
    let!(:todo) { create(:todo, user:) }

    it "trashes a todo, hides it from the list and keeps the row" do
      patch "/api/v1/todos/#{todo.id}/trash", as: :json

      expect(response).to have_http_status(:ok)
      expect(json.dig("todo", "trashed")).to be(true)
      expect(Todo.exists?(todo.id)).to be(true)

      get "/api/v1/todos"
      expect(json["todos"]).to be_empty
    end

    it "lists trashed todos separately and restores them" do
      patch "/api/v1/todos/#{todo.id}/trash", as: :json

      get "/api/v1/todos/trash"
      expect(json["todos"].pluck("id")).to eq([ todo.id ])

      patch "/api/v1/todos/#{todo.id}/restore", as: :json
      expect(json.dig("todo", "trashed")).to be(false)

      get "/api/v1/todos"
      expect(json["todos"].pluck("id")).to eq([ todo.id ])
    end

    it "leaves trashed todos out of clear_completed" do
      completed = create(:todo, :completed, user:)
      create(:todo, :completed, user:).trash!

      delete "/api/v1/todos/clear_completed"

      expect(json["deleted_count"]).to eq(1)
      expect(Todo.exists?(completed.id)).to be(false)
    end
  end

  describe "tags" do
    it "creates tags on demand and filters by them" do
      post "/api/v1/todos", params: { todo: { title: "Write specs", tag_names: [ "Work", "urgent" ] } },
                            as: :json

      expect(response).to have_http_status(:created)
      expect(json.dig("todo", "tags")).to eq(%w[urgent work])

      create(:todo, user:, title: "Untagged")

      get "/api/v1/todos", params: { tag: "work" }
      expect(json["todos"].pluck("title")).to eq([ "Write specs" ])
    end
  end

  describe "optimistic locking" do
    let!(:todo) { create(:todo, user:, title: "Original") }

    it "accepts an edit that carries the current lock_version" do
      patch "/api/v1/todos/#{todo.id}",
            params: { todo: { title: "First", lock_version: todo.lock_version } }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json.dig("todo", "title")).to eq("First")
      expect(json.dig("todo", "lock_version")).to eq(todo.lock_version + 1)
    end

    it "returns 409 when someone else already changed the todo" do
      stale_version = todo.lock_version
      todo.update!(title: "Changed by someone else")

      patch "/api/v1/todos/#{todo.id}",
            params: { todo: { title: "Mine", lock_version: stale_version } }, as: :json

      expect(response).to have_http_status(:conflict)
      expect(json["error"]).to match(/changed by someone else/i)
      expect(todo.reload.title).to eq("Changed by someone else")
    end
  end

  describe "POST /api/v1/todos/bulk" do
    it "creates many todos in one request" do
      post "/api/v1/todos/bulk",
           params: { todos: { titles_text: "Buy milk\nWalk the dog", priority: "high" } },
           as: :json

      expect(response).to have_http_status(:created)
      expect(json["todos"].pluck("title")).to eq([ "Buy milk", "Walk the dog" ])
      expect(json["todos"]).to all(include("priority" => "high"))
    end

    it "returns 422 and creates nothing when a line is invalid" do
      post "/api/v1/todos/bulk",
           params: { todos: { titles_text: "Fine\n#{'x' * 200}" } }, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(user.todos.count).to eq(0)
    end
  end
end
