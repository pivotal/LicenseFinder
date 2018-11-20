# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe ProjectFinder do
    describe '#find_projects' do
      it 'returns absolute paths for projects with active package managers' do
        finder = ProjectFinder.new('spec/fixtures/composite')

        active_projects = finder.find_projects
        expect(has_project_path?(active_projects, 'composite')).to be true
        expect(has_project_path?(active_projects, 'composite/project1')).to be true
        expect(has_project_path?(active_projects, 'composite/project2')).to be true
        expect(has_project_path?(active_projects, 'composite/not_a_project')).to be false
      end

      it 'searches for projects in project_path' do
        expect(Dir).to receive(:glob).with('/path/to/projects/**/').and_return([])
        ProjectFinder.new('/path/to/projects').find_projects
      end

      it 'finds nested dependencies' do
        finder = ProjectFinder.new('spec/fixtures/composite')

        active_projects = finder.find_projects
        expect(has_project_path?(active_projects, 'pivotal/foo')).to be true
      end
    end

    def has_project_path?(projects, path)
      projects.any? { |p| p.end_with?(path) }
    end
  end
end
