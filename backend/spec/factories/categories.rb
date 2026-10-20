FactoryBot.define do
  factory :category do
    user
    sequence(:name) { |n| "Category #{n}" }
    color { "#6366f1" }
  end
end
