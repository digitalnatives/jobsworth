When /I am on a property edit page$/ do
  sleep 1
  visit edit_property_path Property.first
end

When /I am on a customer edit page$/ do
  sleep 1
  visit edit_customer_path @current_user.company.customers.first
end

Given /I have all score rules related test data and logged in as (\w+)$/ do |u|
  @current_user = user = FactoryGirl.create(u.to_sym)
  project = FactoryGirl.create :project, :company => user.company
  FactoryGirl.create :project_permission, :company => user.company, :user => user, :project => project

  FactoryGirl.create(:milestone, :user => user, :project => project)
  FactoryGirl.create(:customer, :company => user.company)
  step %Q{I am logged in as current user}
end
