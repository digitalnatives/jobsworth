FactoryGirl.define do
  factory :milestone do
    sequence(:name) { |n| "Milestone #{n}" }
    association :company, :factory => :company
    association :project, :factory => :project
    status_name { :open }
  end
end
