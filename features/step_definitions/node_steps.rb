Given(/^A package file with dependencies$/) do
  @user = ::DSL::User.new
  @user.create_node_app
end

Then(/^I should see a Node dependency with a license$/) do
  @output.should =~ /^jshint, 2.1.9, MIT$/
end