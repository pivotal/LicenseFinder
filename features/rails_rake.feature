Feature: The rake task is automatically made available in Rails project
  So that I do not have to modify the Rails rakefile
  As an application developer
  I want the license_finder rake task automatically loaded for me in a rails project

  Scenario: The application is a Rails app
    Given I have a rails app with license finder
    When I run "rake license_finder"
    Then I should see "Dependencies that need approval:" in its output
