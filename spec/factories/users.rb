FactoryGirl.define do
  factory :user do
    association :company, :factory => :company
    sequence(:name) { |n| "User #{n}" }
    sequence(:username) { |n| "username#{n}" }
    sequence(:email) { |n| "username#{n}@company.com" }
    password "123456"

    factory :admin do
      admin 1
    end
  end
end