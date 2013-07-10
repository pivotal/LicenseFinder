Feature: Whitelist licenses
  As a developer
  I want to whitelist certain OSS licenses that my business has pre-approved
  So that any dependencies with those licenses do not show up as action items

  Scenario: Whitelist with MIT License alternative name "Expat" should whitelist "MIT" licenses
    Given I have an app with license finder that depends on an MIT license
    When I whitelist the Expat license
    Then I should not see a MIT licensed gem unapproved

  Scenario: Viewing the whitelisted licenses from command line
    Given I have an app with license finder
    When I whitelist the Expat license
    And I view the whitelisted licenses from the command line
    Then I should see Expat in the output
