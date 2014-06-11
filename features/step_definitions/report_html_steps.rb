Given(/^my app depends on a gem with specific details$/) do
  @gem_name = "mit_licensed_gem"
  @gem_homepage = "http://mit_licensed_gem.github.com"
  @table = {
    license:       "MIT",
    summary:       "mit is cool",
    description:   "seriously",
    version:       "0.0.1",
    bundler_group: "test"
  }
  @user.create_gem(@gem_name,
    license:     @table[:license],
    summary:     @table[:summary],
    description: @table[:description],
    version:     @table[:version],
    homepage:    @gem_homepage,
  )
  @user.depend_on_local_gem(@gem_name, groups: [@table[:bundler_group]])
end

Given(/^my app depends on MIT and GPL licensed gems$/) do
  @user.create_and_depend_on_gem 'gpl_licensed_gem', license: "GPL"
  @user.create_and_depend_on_gem 'mit_licensed_gem', license: "MIT"
end

When(/^I whitelist the MIT license$/) do
  @user.configure_license_finder_whitelist ["MIT"]
  @user.execute_command "license_finder --quiet"
end

Then(/^I should see my specific gem details listed in the html$/) do
  @user.in_gem_html(@gem_name) do |section|
    section.find("a[href='#{@gem_homepage}']", text: @gem_name).should be
    @table.values.each do |property_value|
      section.should have_content property_value
    end
  end
end

Then(/^I should see the GPL gem unapproved in html$/) do
  is_html_status?('gpl_licensed_gem', 'unapproved')
end

Then(/^the MIT gem approved in html$/) do
  is_html_status?('mit_licensed_gem', 'approved')
end

Then(/^I should see only see GPL liceneses as unapproved in the html$/) do
  @user.in_html do |page|
    page.should have_content '1 GPL'
    action_items = page.find('.action-items')
    action_items.should have_content '(GPL)'
  end
end

def is_html_status?(gem, approval)
  @user.in_gem_html(gem) do |gpl_gem|
    gpl_gem[:class].split(' ').should include approval
  end
end
