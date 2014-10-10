Given(/^A build.gradle file with dependencies$/) do
  @user = ::DSL::User.new
  @user.create_gradle_app
end

Then(/^I should see a Gradle dependency with a license$/) do
  expect(@user).to be_seeing_line "junit, 4.11, Common Public License Version 1.0"
end
