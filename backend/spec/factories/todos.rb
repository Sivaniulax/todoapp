FactoryBot.define do
  factory :todo do
    user
    sequence(:title) { |n| "Todo #{n}" }
    priority { :medium }

    trait :in_progress do
      status { "in_progress" }
    end

    trait :completed do
      status { "completed" }
      completed_at { Time.current }
    end

    trait :archived do
      status { "archived" }
      completed_at { 1.day.ago }
    end

    trait :overdue do
      due_date { 2.days.ago.to_date }
    end
  end
end
