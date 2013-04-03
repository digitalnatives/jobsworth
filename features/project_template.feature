Feature: Project Template

  @javascript
  Scenario: Create a Project Template
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
     When I follow list item "Project Template" within "#content"
      And I follow "New milestone"
      And I fill in "Name" with "Project Template First Milestone"
      And I fill datepicker "milestone_due_at" with "20/01/2013"
      And I press "Create"
     Then I should see "Project Template First Milestone"
     When I am on clone project page 
      And I fill in "Name" with "Clone of Project Template" 
      And I press "Create"
     When I am on current common user 1. "project" edit page
     Then I should see "Project Template First Milestone"
