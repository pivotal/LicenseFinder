Feature: Set a dependency's license through a command line interface
  So that my dependencies all have the correct licenses
  As an application developer
  I want a command line interface to set licenses for specific dependencies

  Scenario: Setting a license for a dependency
    Given I have an app with license finder
    And my app depends on a gem "other_license_gem" licensed with "other"
    When I run "license_finder"
    When I run "license_finder -l MIT other_license_gem"
    Then I should see the following settings for "other_license_gem":
      """
        license: "MIT"
      """
