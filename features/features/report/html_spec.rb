# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'HTML report' do
  # As a non-technical product owner
  # I want an HTML report
  # So that I can easily review my application's dependencies and licenses

  let(:developer) { LicenseFinder::TestingDSL::User.new }
  let(:product_owner) { LicenseFinder::TestingDSL::User.new }

  specify 'shows basic dependency data' do
    gem_name = 'a_gem'
    gem_group = 'test'
    gem_attributes = {
      license: 'MIT',
      summary: 'gem is cool',
      description: 'seriously',
      version: '0.0.1',
      homepage: 'http://a-gem.github.com'
    }

    project = developer.create_ruby_app
    gem = developer.create_gem gem_name, gem_attributes
    project.depend_on gem, groups: [gem_group]

    product_owner.view_html.in_dep(gem_name) do |section|
      expect(section.find("a[href='#{gem_attributes[:homepage]}']", text: gem_name)).to be
      expect(section).to have_content gem_attributes[:license]
      expect(section).to have_content gem_attributes[:summary]
      expect(section).to have_content gem_attributes[:description]
      expect(section).to have_content gem_attributes[:version]
      expect(section).to have_content gem_group
    end
  end

  specify 'shows approval status of dependencies' do
    developer.create_empty_project
    developer.execute_command 'license_finder dependencies add gpl_dep GPL'
    developer.execute_command 'license_finder dependencies add mit_dep MIT'
    developer.execute_command 'license_finder whitelist add MIT'

    html = product_owner.view_html
    expect(html).to be_unapproved 'gpl_dep'
    expect(html).to be_approved 'mit_dep'

    expect(html).to have_content '1 GPL'
    action_items = html.find('.action-items')
    expect(action_items).to have_content '(GPL)'
    expect(action_items).not_to have_content 'MIT'
  end
end
