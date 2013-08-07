Given(/^A requirements file with dependencies$/) do
  @user = ::DSL::User.new
  @user.create_python_app
end

Then(/^I should see a Python dependency with a license$/) do
  @output.should =~ /^argparse, 1.2.1, Python Software Foundation License$/
end
