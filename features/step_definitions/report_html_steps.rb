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
  @user.run_license_finder
end

Then(/^I should see my specific gem details listed in the html$/) do
  @user.in_dep_html(@gem_name) do |section|
    expect(section.find("a[href='#{@gem_homepage}']", text: @gem_name)).to be
    @table.values.each do |property_value|
      expect(section).to have_content property_value
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
    expect(page).to have_content '1 GPL'
    action_items = page.find('.action-items')
    expect(action_items).to have_content '(GPL)'
  end
end

def is_html_status?(gem, approval)
  @user.in_dep_html(gem) do |gpl_gem|
    expect(gpl_gem[:class].split(' ')).to include approval
  end
end
