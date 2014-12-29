Feature: Whitelist licenses
  As a developer
  I want to whitelist certain OSS licenses that my business has pre-approved
  So that any dependencies with those licenses do not show up as action items

  Scenario: Adding a license to the whitelist
    Given I have an app
    When I whitelist the Expat license
    And I view the whitelisted licenses
    Then I should see MIT in the output

  Scenario: Depending on whitelisted licenses
    Given I have an app that depends on an BSD license
    When I whitelist the BSD license
    Then I should not see a BSD licensed gem unapproved

  Scenario: Removing a license from the whitelist
    Given I have an app
    When I whitelist the Expat license
    And I remove Expat from the whitelist
    And I view the whitelisted licenses
    Then I should not see MIT in the output

  Scenario: Whitelisting license aliases
    Given I have an app that depends on an MIT license
    When I whitelist the Expat license
    Then I should not see a MIT licensed gem unapproved
