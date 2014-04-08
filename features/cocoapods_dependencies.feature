@ios
Feature: Tracking CocoaPods Dependencies
  So that I can track CocoaPods dependencies
  As an application developer using license finder
  I want to be able to manage CocoaPods dependencies

  Scenario: See the dependencies from the Podfile
    Given A Podfile with dependencies
    When I run license_finder
    Then I should see a CocoaPods dependency with a license