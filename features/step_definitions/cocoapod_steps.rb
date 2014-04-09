Given(/^A Podfile with dependencies$/) do
  @user = ::DSL::User.new
  @user.create_cocoapods_app
end

Then(/^I should see a CocoaPods dependency with a license$/) do
  @user.should be_seeing_line "ABTest, 0.0.5, MIT"
end
