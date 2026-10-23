class UserMailer < ApplicationMailer
  # Sent once, when a guest upgrades or someone signs up.
  def welcome(user)
    @user = user
    mail to: @user.email, subject: t("mailers.user_mailer.welcome.subject", name: @user.name)
  end
end
