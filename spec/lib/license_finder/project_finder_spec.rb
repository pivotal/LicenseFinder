require 'spec_helper'

module LicenseFinder
  describe ProjectFinder do
    describe '#find_projects' do
      it 'finds projects' do
        finder = ProjectFinder.new('spec/fixtures/composite')

        active_projects = finder.find_projects
        expect(active_projects.any? {|p| p.end_with?('/composite/project1') }).to be true
        expect(active_projects.any? {|p| p.end_with?('/composite/project2') }).to be true
        expect(active_projects.any? {|p| p.end_with?('/composite/not_a_project') }).to be false
      end

      it 'searches for projects in project_path' do
        expect(Dir).to receive(:glob).with('/path/to/projects/**/').and_return([])
        ProjectFinder.new('/path/to/projects').find_projects
      end
    end
  end
end
