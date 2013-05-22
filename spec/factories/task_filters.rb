FactoryGirl.define do
  factory :task_filter do
    sequence(:name) { |n| "TaskFilter ##{n}" }
    association :user
    company { user.company }
  end
end
