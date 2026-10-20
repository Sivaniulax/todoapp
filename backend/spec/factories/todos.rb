FactoryBot.define do
  factory :todo do
    user
    sequence(:title) { |n| "Todo #{n}" }
    priority { :medium }

    trait :completed do
      completed { true }
    end

    trait :overdue do
      due_date { 2.days.ago.to_date }
    end
  end
end
