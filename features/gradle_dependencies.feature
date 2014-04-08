Feature: Tracking Gradle Dependencies
  So that I can track Gradle dependencies
  As an application developer using license finder
  I want to be able to manage Gradle dependencies

  Scenario: See the dependencies from the build.gradle file
    Given A build.gradle file with dependencies
    When I run license_finder
    Then I should see a Gradle dependency with a license