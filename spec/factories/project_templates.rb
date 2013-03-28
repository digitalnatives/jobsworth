FactoryGirl.define do
  factory :project_template do
    sequence(:name) { |n| "Project Template#{n}" }
    association :company, :factory => :company
    association :customer, :factory => :customer
  end
end
