Given /^I am on a project edit page$/ do
  visit edit_project_path Project.first
end

Given /^I am on a project show page$/ do
  visit project_path Project.first
end

Given /^I have all project template related test data and logged in as "([^"]+)"$/ do |user|
  @current_user = FactoryGirl.create(:admin)
  FactoryGirl.create(:user,
                     :company => @current_user.company,
                     :name => "Autocomplete Test User")
  FactoryGirl.create(:project, :users => [ @current_user ], :company => @current_user.company)
  @customer_company = FactoryGirl.create(:customer,
                                         :company => @current_user.company,
                                         :name => "First Test Customer Company")
  step %Q{I am logged in as current user}
end

When /^I am on clone project page$/ do
  visit clone_project_path ProjectTemplate.last
end
