Feature: Whitelist licenses
  As a developer
  I want to whitelist certain OSS licenses that my business has pre-approved
  So that any dependencies with those licenses do not show up as action items

  Scenario: Whitelist with MIT License alternative name "Expat" should whitelist "MIT" licenses
    Given I have an app with license finder that depends on an MIT license
    When I whitelist the Expat license
    Then I should not see a MIT licensed gem unapproved
