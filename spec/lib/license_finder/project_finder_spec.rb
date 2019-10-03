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

      context 'when a directory is a sub gradle project' do
        subject { ProjectFinder.new('spec/fixtures/gradle-with-subprojects') }

        it 'does not include gradle subproject in the result' do
          active_projects = subject.find_projects
          expect(has_project_path?(active_projects, 'gradle-with-subprojects')).to be_truthy
          expect(has_project_path?(active_projects, 'submodule-1')).to be_falsey
          expect(has_project_path?(active_projects, 'kotlin-submodule-1')).to be_falsey
        end

        context 'and includes another package manager config' do

          it 'includes gradle subproject in the result' do
            active_projects = subject.find_projects
            expect(has_project_path?(active_projects, 'gradle-with-subprojects')).to be_truthy
            expect(has_project_path?(active_projects, 'submodule-2')).to be_truthy
          end
        end
      end


    end

    def has_project_path?(projects, path)
      projects.any? { |p| p.end_with?(path) }
    end
  end
end
