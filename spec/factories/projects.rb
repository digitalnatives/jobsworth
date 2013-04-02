FactoryGirl.define do
  factory :abstract_project do
    sequence(:name) { |n| "Project #{n}" }
    association :company, :factory => :company
    association :customer, :factory => :customer

    factory :project do
      type 'Project'
    end

    factory :project_template do
      start_at Date.today
      type 'ProjectTemplate'
    end
  end
end
