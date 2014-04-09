Feature: Setting a dependency's license
  So that my dependencies all have the correct licenses
  As an application developer
  I want to be able to manually set licenses

  Scenario: Setting a license for a dependency
    Given I have an app that depends on a few gems without known licenses
    When I set one gem's license to MIT from the command line
    Then I should see that gem's license set to MIT
    And I should see other gems have not changed their licenses

  Scenario: Keep manually assigned license dependencies
    Given I have an app that depends on a manually licensed gem
    When I run license_finder
    Then the gem should keep its manually assigned license

