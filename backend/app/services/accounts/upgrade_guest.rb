# Turns a guest into a member, keeping their todos.
module Accounts
  class UpgradeGuest
    def self.call(...) = new(...).call

    def initialize(user, attributes)
      @user = user
      @attributes = attributes
    end

    def call
      raise ApiError::Forbidden, I18n.t("api.errors.guests_cannot_upgrade") unless user.guest?

      ApplicationRecord.transaction do
        user.assign_attributes(attributes)
        user.role = :member
        user.guest_expires_at = nil
        user.save!
      end

      # Only now that the row is committed is there a real address to write to.
      user.send_welcome_email
      user
    end

    private

    attr_reader :user, :attributes
  end
end
