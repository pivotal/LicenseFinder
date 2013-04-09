Feature: Text Report
  So that I can easily view a report outlining my application dependencies and licenses
  As a non-technical application product owner
  I want license finder to generate an easy-to-understand text report

  Scenario: Viewing dependencies
    Given I have an app with license finder that depends on a gem with license and version details
    When I run license_finder
    Then I should see those version and license details in the dependencies.txt file
