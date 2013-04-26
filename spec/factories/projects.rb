FactoryGirl.define do
  factory :abstract_project, class: 'AbstractProject' do
    sequence(:name) { |n| "Project #{n}" }
    association :company, :factory => :company
    association :customer, :factory => :customer

    factory :project, class: 'Project'

    factory :project_template, class: 'ProjectTemplate' do
      start_at Date.today
    end
  end
end
