FactoryGirl.define do
  factory :abstract_task do
    sequence(:name) { |n| "#{type} #{n}" }
    description { Faker::Lorem.paragraph }
    weight_adjustment 0

    association :company, :factory => :company
    association :project, :factory => :project


    trait(:with_customers) do
      ignore { customer_count 1 }
      customers { FactoryGirl.create_list :customer, customer_count }
    end

    trait :with_todos do
      ignore { todos_count 3 }
      after :create do |task, evaluator|
        FactoryGirl.create_list :todo, evaluator.todos_count, task: task
      end
    end

    factory :task_record, aliases: [:task], class: 'TaskRecord' do
      factory :task_with_customers, traits: [:with_customers]
      factory :task_with_todos,     traits: [:with_todos]
    end

    factory :template, aliases: [:task_template], class: 'Template' do
      factory :template_with_todos, traits: [:with_todos]
    end
  end
end
