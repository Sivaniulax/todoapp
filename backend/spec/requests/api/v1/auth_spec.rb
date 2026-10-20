require "rails_helper"

RSpec.describe "Auth API" do
  let(:signup_params) do
    { user: { name: "Sivani", email: "sivani@example.com", password: "password123", password_confirmation: "password123" } }
  end

  describe "POST /api/v1/auth/signup" do
    it "creates a member and returns a token" do
      post "/api/v1/auth/signup", params: signup_params, as: :json

      expect(response).to have_http_status(:created)
      expect(json["token"]).to be_present
      expect(json["user"]).to include("email" => "sivani@example.com", "role" => "member")
      expect(json["user"]).not_to have_key("password_digest")
    end

    it "ignores a role sent by the client" do
      post "/api/v1/auth/signup", params: { user: signup_params[:user].merge(role: "admin") }, as: :json
      expect(json.dig("user", "role")).to eq("member")
    end

    it "returns validation errors" do
      create(:user, email: "sivani@example.com")
      post "/api/v1/auth/signup", params: signup_params, as: :json

      expect(response).to have_http_status(:unprocessable_content)
      expect(json["details"]["email"]).to include("has already been taken")
    end

    it "returns 400 when the user key is missing" do
      post "/api/v1/auth/signup", params: { name: "x" }, as: :json
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "me@example.com", password: "password123") }

    it "logs in with the right password (email is case-insensitive)" do
      post "/api/v1/auth/login", params: { email: "ME@example.com", password: "password123" }, as: :json

      expect(response).to have_http_status(:ok)
      expect(json.dig("user", "id")).to eq(user.id)
    end

    it "rejects a wrong password" do
      post "/api/v1/auth/login", params: { email: "me@example.com", password: "wrong-password" }, as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq("Invalid email or password")
    end
  end

  describe "POST /api/v1/auth/guest" do
    it "creates a guest session and enqueues cleanup" do
      expect { post "/api/v1/auth/guest", as: :json }
        .to change(User.guest, :count).by(1)
        .and have_enqueued_job(CleanupExpiredGuestsJob)

      expect(response).to have_http_status(:created)
      expect(json["user"]).to include("role" => "guest", "email" => nil)
      expect(json.dig("user", "limits", "max_todos")).to eq(User::GUEST_TODO_LIMIT)
    end
  end

  describe "POST /api/v1/auth/upgrade" do
    it "upgrades a guest to a member" do
      guest = create(:user, :guest)
      post "/api/v1/auth/upgrade", params: signup_params, headers: auth_headers(guest), as: :json

      expect(response).to have_http_status(:ok)
      expect(json.dig("user", "role")).to eq("member")
      expect(guest.reload).to be_member
    end

    it "is forbidden for members" do
      post "/api/v1/auth/upgrade", params: signup_params, headers: auth_headers(create(:user)), as: :json
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "GET /api/v1/me" do
    it "returns the current user" do
      user = create(:user)
      get "/api/v1/me", headers: auth_headers(user)
      expect(json.dig("user", "id")).to eq(user.id)
    end

    it "requires a token" do
      get "/api/v1/me"
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects a garbage token" do
      get "/api/v1/me", headers: { "Authorization" => "Bearer nope" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects an expired guest" do
      guest = create(:user, :guest)
      headers = auth_headers(guest)
      guest.update!(guest_expires_at: 1.minute.ago)

      get "/api/v1/me", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
