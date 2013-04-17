Given(/^I have an app with license finder$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
end

Given(/^my app depends on a gem with specific details$/) do
  @gem_name = "mit_licensed_gem"
  @table = {
    license:        "MIT",
    summary:        "mit is cool",
    description:    "seriously",
    version:        "0.0.1",
    homepage:       "http://mit_licensed_gem.github.com",
    bundler_groups: "test"
  }
  @user.add_dependency_to_app(@gem_name,
    :license        => @table[:license],
    :summary        => @table[:summary],
    :description    => @table[:description],
    :version        => @table[:version],
    :homepage       => @table[:homepage],
    :bundler_groups => @table[:bundler_groups]
  )
end

Given(/^my app depends on MIT and GPL licensed gems$/) do
  @user.add_dependency_to_app 'gpl_licensed_gem', :license => "GPL"
  @user.add_dependency_to_app 'mit_licensed_gem', :license => "MIT"
end

When(/^I whitelist the MIT license$/) do
  @user.configure_license_finder_whitelist ["MIT"]
  @user.execute_command "license_finder -q"
end

Then(/^I should see my specific gem details listed in the html$/) do
  html = File.read(@user.dependencies_html_path)
  page = Capybara.string(html)
  section = page.find("##{@gem_name}")

  @table.first.each do |property_name, property_value|
    section.should have_content property_value
  end
end

Then(/^I should see the GPL gem unapproved in html$/) do
  is_html_status?('gpl_licensed_gem', 'unapproved')
end

Then(/^the MIT gem approved in html$/) do
  is_html_status?('mit_licensed_gem', 'approved')
end

Then(/^I should see only see GPL liceneses as unapproved in the html$/) do
  html = File.read(@user.dependencies_html_path)
  page = Capybara.string(html)
  page.should have_content '9 total'
  page.should have_content '1 unapproved'
  page.should have_content '1 GPL'
end

def is_html_status?(gem, approval)
  html = File.read(@user.dependencies_html_path)
  page = Capybara.string(html)
  gpl_gem = page.find("##{gem}")
  gpl_gem[:class].should == approval
end
