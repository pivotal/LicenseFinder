Feature: License Finder command line executable
  So that I can manage my application's dependencies and licenses
  As an application developer
  I want a command-line interface

  Scenario: Auditing an application with unapproved licenses
    Given I have an app with an unapproved dependency
    When I run license_finder
    Then it should exit with status code 1
    And should list my unapproved dependency in the output

  Scenario: Auditing an application with approved licenses
    Given I have an app with an unapproved dependency
    When I whitelist everything I can think of
    Then it should exit with status code 0
    And I should see all dependencies approved for use

  Scenario: Viewing help for license_finder subcommand
    Given I have an app
    When I run license_finder help on a specific command
    Then I should see the correct subcommand usage instructions

  Scenario: Viewing help for license_finder default
    Given I have an app
    When I run license_finder help
    Then I should see the default usage instructions

  Scenario: Running without a configuration file
    Given I have an app that has no config directory
    When I run license_finder
    Then it creates a config directory with the license_finder config

  Scenario: Viewing License Finder's own license
    Given I have an app
    When I run license_finder
    Then I should see License Finder has the MIT license

