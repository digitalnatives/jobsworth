FactoryGirl.define do
  factory :customer do
    sequence(:name) { |n| "Company#{n}" }
  end
end
