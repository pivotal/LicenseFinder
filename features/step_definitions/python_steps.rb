Given(/^A requirements file with dependencies$/) do
  @user = ::DSL::User.new
  @user.create_python_app
end

Then(/^I should see a Python dependency with a license$/) do
  @output.should =~ /^jasmine, 1.3.1, MIT$/
end