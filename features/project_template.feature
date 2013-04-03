Feature: Project Template

  @javascript
  Scenario: Create a Project Template and clone it to a project
    Given I have all project template related test data and logged in as "admin"
      And I browse with resolution 1024x768 
     When I am on the new project template page
      And I fill in "Name" with "Project Template" 
      And I should see no autocomplete suggestions
      And I fill in "Company" autocomplete with "first"
      And I should see 1 autocomplete suggestions
      And I pick "First Test Customer Company" autocomplete option
      And I fill datepicker "project_start_at" with "01/01/2013"
      And I press "Create"
     Then I should see "Project Templates"
     # Assign milestone
     When I follow list item "Project Template" within "#content"
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
     # Clone project
     When I am on clone project page 
      And I fill in "Name" with "Clone of Project Template" 
      And I fill datepicker "project_start_at" with "02/02/2013"
      And I press "Create"
      And I am on current common user 1. "project" edit page
     Then I should see "Project Template First Milestone"
      And I should see "Thu, 21 Feb 2013" within "#milestones-pane"
      And I follow "Access Control"
      And I should see "User 1"
      And I should see "Autocomplete Test User"
