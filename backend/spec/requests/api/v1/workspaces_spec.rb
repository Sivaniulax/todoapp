require "rails_helper"

RSpec.describe "Workspace isolation" do
  let(:workspace) { create(:workspace, name: "Kitchen table") }
  let(:member) { create(:user, workspace:) }
  let(:colleague) { create(:user, workspace:) }
  let(:outsider) { create(:user) }

  before { sign_in member }

  it "shows every todo in the workspace, whoever wrote it" do
    mine = create(:todo, user: member, title: "Mine")
    theirs = create(:todo, user: colleague, title: "Theirs")
    create(:todo, user: outsider, title: "Not ours")

    get "/api/v1/todos"

    expect(json["todos"].pluck("title")).to contain_exactly(mine.title, theirs.title)
  end

  it "hides another workspace's todo behind a 404" do
    elsewhere = create(:todo, user: outsider)

    get "/api/v1/todos/#{elsewhere.id}"

    expect(response).to have_http_status(:not_found)
  end

  it "will not let a member edit a colleague's todo" do
    theirs = create(:todo, user: colleague, title: "Theirs")

    patch "/api/v1/todos/#{theirs.id}", params: { todo: { title: "Mine now" } }, as: :json

    expect(response).to have_http_status(:forbidden)
    expect(theirs.reload.title).to eq("Theirs")
  end

  it "lets an admin edit anything in the workspace" do
    admin = create(:user, :admin, workspace:)
    theirs = create(:todo, user: colleague)
    sign_in admin

    patch "/api/v1/todos/#{theirs.id}", params: { todo: { title: "Tidied up" } }, as: :json

    expect(response).to have_http_status(:ok)
    expect(theirs.reload.title).to eq("Tidied up")
  end

  it "keeps categories inside the workspace too" do
    ours = create(:category, user: colleague, name: "Shared")
    create(:category, user: outsider, name: "Theirs")

    get "/api/v1/categories"

    expect(json["categories"].pluck("name")).to eq([ ours.name ])
  end

  it "stamps a new todo with the current workspace" do
    post "/api/v1/todos", params: { todo: { title: "Fresh" } }, as: :json

    expect(Todo.find(json.dig("todo", "id")).workspace).to eq(workspace)
  end

  it "counts across workspaces on the admin dashboard" do
    create(:todo, user: member)
    create(:todo, user: outsider)
    sign_in create(:user, :admin, workspace:)

    get "/api/v1/admin/stats"

    expect(json.dig("todos", "total")).to eq(2)
  end
end
