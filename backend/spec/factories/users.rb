FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "User #{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    role { :member }

    trait :admin do
      role { :admin }
    end

    trait :guest do
      name { "Guest" }
      sequence(:email) { |n| "guest-#{n}@guest.todoapp.local" }
      role { :guest }
      guest_expires_at { 24.hours.from_now }
    end
  end
end
