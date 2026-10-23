require "rails_helper"

RSpec.describe "Todo history" do
  let(:user) { create(:user) }
  let(:todo) { create(:todo, user:, title: "Draft the letter") }

  before { sign_in user }

  it "records what changed, in what order, and who did it" do
    patch "/api/v1/todos/#{todo.id}", params: { todo: { title: "Post the letter" } }, as: :json
    patch "/api/v1/todos/#{todo.id}/complete", as: :json

    get "/api/v1/todos/#{todo.id}/history"

    expect(response).to have_http_status(:ok)
    events = json["versions"]

    expect(events.pluck("event")).to eq(%w[update update create])
    # The create happened in the test setup, outside any request, so only
    # the two edits carry a user.
    expect(events.pluck("user_id")).to eq([ user.id, user.id, nil ])

    latest, rename = events
    expect(latest["changes"]["status"]).to eq("from" => "pending", "to" => "completed")
    expect(rename["changes"]["title"]).to eq("from" => "Draft the letter", "to" => "Post the letter")
  end

  it "leaves the noisy columns out of the trail" do
    patch "/api/v1/todos/#{todo.id}", params: { todo: { title: "Something else" } }, as: :json

    get "/api/v1/todos/#{todo.id}/history"

    expect(json["versions"].first["changes"].keys).not_to include("lock_version", "updated_at")
  end

  it "keeps the trail after the todo is trashed" do
    patch "/api/v1/todos/#{todo.id}/trash", as: :json

    get "/api/v1/todos/#{todo.id}/history"

    expect(json["versions"].first["changes"]).to have_key("discarded_at")
  end

  it "will not show another workspace's history" do
    elsewhere = create(:todo)

    get "/api/v1/todos/#{elsewhere.id}/history"

    expect(response).to have_http_status(:not_found)
  end
end
