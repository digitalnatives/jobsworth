Feature: Project Template

  @javascript
  Scenario: Create a Project Template and clone it to a project
    Given I have all project template related test data and logged in as "admin"
      And I browse with resolution 1024x768
     When I am on the new project template page
      And I fill in "Name" with "Project Template Sample"
      And I should see no autocomplete suggestions
      And I fill in "Company" autocomplete with "first"
      And I should see 1 autocomplete suggestions
      And I pick "First Test Customer Company" autocomplete option
      And I fill datepicker "project_start_at" with "01/01/2013"
      And I press "Create"
     Then I should see "Project successfully created"
     # Assign milestone
     When I follow list item "Project Template Sample" within "#content"
      And I follow "New milestone"
      And I fill in "Name" with "Project Template First Milestone"
      And I fill datepicker "milestone_due_at" with "20/01/2013"
      And I press "Create"
     Then I should see "Project Template First Milestone"
     # Assign one more user
     When I am on current common user 1. "project_template" edit page
      And I follow "Access Control"
      And I should see no autocomplete suggestions
      And I fill in "project_user_name_autocomplete" autocomplete with "auto"
      And I should see 1 autocomplete suggestions
      And I pick "Autocomplete Test User" autocomplete option
      And I should see no autocomplete suggestions
     # Assign template task
     When I am on the new task template page
      And I fill in "task_name" with "Task Template"
      And I select "Project Template Sample" from "task_project_id"
      And I press "Save"
     When I am on the tasks page
     Then I should not see "Task Template"
     # Clone project
     When I am on clone project page
      And I fill in "Name" with "Clone of Project Template Sample"
      And I fill datepicker "project_start_at" with "02/02/2013"
      And I press "Create"
      And I am on current common user 1. "project" edit page
     Then I should see "Project Template First Milestone"
      And I should see "Thu, 21 Feb 2013" within "#milestones-pane"
      And I follow "Access Control"
      And I should see "User 1"
      And I should see "Autocomplete Test User"
     When I am on the tasks page
      And I follow "Clone of Project Template Sample" within "#task_filters"
     Then I should see "Task Template"
