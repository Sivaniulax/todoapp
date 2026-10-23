require "rails_helper"

RSpec.describe "Tags API" do
  let(:user) { create(:user) }
  before { sign_in user }

  it "lists the current user's tags alphabetically with their usage count" do
    todo = create(:todo, user:)
    todo.update!(tag_names: [ "work", "admin" ])
    create(:tag, user: create(:user), name: "someone-else")

    get "/api/v1/tags"

    expect(response).to have_http_status(:ok)
    expect(json["tags"].pluck("name")).to eq(%w[admin work])
    expect(json["tags"].first["todos_count"]).to eq(1)
  end

  it "deletes a tag and untags the todos that used it" do
    todo = create(:todo, user:)
    todo.update!(tag_names: [ "work" ])
    tag = user.tags.sole

    delete "/api/v1/tags/#{tag.id}"

    expect(response).to have_http_status(:no_content)
    expect(todo.reload.tag_names).to be_empty
    expect(Todo.exists?(todo.id)).to be(true)
  end

  it "returns 404 for someone else's tag" do
    other = create(:tag)

    delete "/api/v1/tags/#{other.id}"

    expect(response).to have_http_status(:not_found)
  end

  it "is forbidden for guests to delete" do
    guest = User.create_guest!
    tag = create(:tag, user: guest)
    sign_in guest

    delete "/api/v1/tags/#{tag.id}"

    expect(response).to have_http_status(:forbidden)
  end
end
