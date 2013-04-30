FactoryGirl.define do
  factory :user do
    association :customer
    company { customer.company }
    sequence(:name) { |n| "User #{n}" }
    sequence(:username) { |n| "username#{n}" }
    sequence(:email) { |n| "username#{n}@company.com" }

    password "123456"
    time_zone "Australia/Sydney"
    date_format "%d/%m/%Y"
    time_format "%H:%M"
    option_tracktime 1
    receive_notifications 1
    receive_own_notifications true

    trait(:admin)          { admin 1 }
    trait(:no_billing)     { association :company, :factory => :company_with_no_billing }
    trait(:no_score_rules) { association :company, :factory => :company_with_no_score_rules }
    trait(:with_customer)  { association :customer }

    factory :admin, :traits => [:admin]
    factory :admin_with_no_billing, :traits => [:admin, :no_billing]
    factory :admin_with_no_score_rules, :traits => [:admin, :no_score_rules]
  end
end
