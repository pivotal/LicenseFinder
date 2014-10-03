Feature: Dependencies with multiple licenses
  As a developer
  I want multi-licensed dependencies to be approved if one license is whitelisted
  So that any dependencies with those licenses do not show up as action items

  Scenario: Depending on whitelisted licenses
    Given I have an app that depends on BSD and GPL-2 licenses
    When I whitelist the GPL-2 license
    Then I should not see a BSD and GPL-2 licensed gem unapproved
