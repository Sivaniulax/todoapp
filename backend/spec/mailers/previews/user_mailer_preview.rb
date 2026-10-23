# Visit http://localhost:3000/rails/mailers to see these in a browser.
class UserMailerPreview < ActionMailer::Preview
  def welcome
    UserMailer.welcome(User.members.first || User.first)
  end
end
