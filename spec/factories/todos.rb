FactoryGirl.define do
  factory :todo do

    association :task
    sequence(:name) { |n| "Todo #{n}" }
    sequence :position

    trait(:undone) { completed_at nil }
    trait :done do
      completed_at 1.day.ago
      association :completed_by_user, factory: :user
    end

    factory :done_todo,   traits: [:done]
    factory :undone_todo, traits: [:undone]

  end
end
