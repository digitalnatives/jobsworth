FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    association :company,   :factory => :company
    association :customer,  :factory => :customer
  end

  factory :project_template do
    sequence(:name) { |n| "Project Template#{n}" }
    association :company, :factory => :company
    association :customer, :factory => :customer
  end
end
