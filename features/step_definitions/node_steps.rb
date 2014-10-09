Given(/^A package file with dependencies$/) do
  @user = ::DSL::User.new
  @user.create_node_app
end

Then(/^I should see a Node dependency with a license$/) do
  expect(@user).to be_seeing_line "http-server, 0.6.1, MIT"
end
