Feature: Set a dependency's license through a command line interface
  So that my dependencies all have the correct licenses
  As an application developer
  I want a command line interface to set licenses for specific dependencies

  Scenario: Setting a license for a dependency
    Given I have an app with license finder that depends on an other licensed gem
    When I set that gems license to MIT from the command line
    Then I should see that other gems license set to MIT
