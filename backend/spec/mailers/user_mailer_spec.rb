require "rails_helper"

RSpec.describe UserMailer do
  describe "#welcome" do
    let(:user) { create(:user, name: "Ada Lovelace", email: "ada@example.com") }
    let(:mail) { described_class.welcome(user) }

    it "is addressed to the new member" do
      expect(mail.to).to eq([ "ada@example.com" ])
      expect(mail.subject).to eq("Welcome to TodoApp, Ada Lovelace")
      expect(mail.from).to eq([ "no-reply@todoapp.dev" ])
    end

    it "greets them in both the html and text parts" do
      expect(mail.html_part.body.to_s).to include("Ada Lovelace")
      expect(mail.text_part.body.to_s).to include("Ada Lovelace")
    end

    it "links to the frontend, not to the API" do
      expect(mail.html_part.body.to_s).to include("http://localhost:5173")
    end
  end

  it "is enqueued when a member signs up, but not for a guest" do
    expect { create(:user) }.to have_enqueued_mail(described_class, :welcome).once
    expect { User.create_guest! }.not_to have_enqueued_mail(described_class, :welcome)
  end
end
