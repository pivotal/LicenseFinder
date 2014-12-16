Given(/^A bower.json file with dependencies$/) do
  @user = ::DSL::User.new
  @user.create_bower_app
end

Then(/^I should see a Bower dependency with a license$/) do
  expect(@user).to be_seeing_line "gmaps, 0.2.30, MIT"
end
