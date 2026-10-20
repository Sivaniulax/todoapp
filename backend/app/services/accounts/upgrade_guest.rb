# Service object: turns a guest into a member while keeping their todos.
#
#   Accounts::UpgradeGuest.call(user, name: "...", email: "...", password: "...", password_confirmation: "...")
module Accounts
  class UpgradeGuest
    def self.call(...) = new(...).call

    def initialize(user, attributes)
      @user = user
      @attributes = attributes
    end

    def call
      raise ApiError::Forbidden, "Only guest accounts can be upgraded" unless user.guest?

      user.assign_attributes(attributes)
      user.role = :member
      user.guest_expires_at = nil
      user.save!
      user
    end

    private

    attr_reader :user, :attributes
  end
end
