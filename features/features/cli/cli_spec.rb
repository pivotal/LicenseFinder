# frozen_string_literal: true

require_relative '../../support/feature_helper'
describe 'License Finder command line executable' do
  # As a developer
  # I want a command-line interface
  # So that I can manage my application's dependencies and licenses

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  specify 'shows usage and subcommand help' do
    developer.create_empty_project

    developer.execute_command 'license_finder help'
    expect(developer).to be_seeing 'license_finder help [COMMAND]'

    developer.execute_command 'license_finder ignored_groups help add'
    expect(developer).to be_seeing 'license_finder ignored_groups add GROUP'
  end

  it "reports `license_finder`'s license is MIT" do
    developer.create_ruby_app # has license_finder as a dependency

    developer.run_license_finder
    expect(developer).to be_seeing_something_like(/license_finder.*MIT/)
  end

  it "reports dependencies' licenses" do
    developer.create_ruby_app # has license_finder as a dependency, which has thor as a dependency

    developer.run_license_finder
    expect(developer).to be_seeing_something_like(/thor.*MIT/)
  end

  specify 'runs default command' do
    developer.create_empty_project

    developer.run_license_finder
    expect(developer).to be_receiving_exit_code(0)
    expect(developer).to be_seeing 'No dependencies recognized!'
  end

  specify 'displays an error if project_path does not exist' do
    developer.create_empty_project

    path = '/path/that/does/not/exist'
    developer.execute_command("license_finder report --project-path=#{path}")
    expect(developer).to be_seeing("Project path '#{File.absolute_path(path)}' does not exist!")
    expect(developer).to be_receiving_exit_code(1)
  end

  # Dep has been deprecated since 2020
  xspecify 'displays an error if symlink to potential license file is dangling' do
    project = LicenseFinder::TestingDSL::BrokenSymLinkDepProject.create
    ENV['GOPATH'] = "#{project.project_dir}/gopath_dep"
    developer.run_license_finder('gopath_dep/src/foo-dep')
    expect(developer).to be_seeing_something_like %r{ERROR: .*my_app/gopath_dep/src/foo-dep/vendor/a/b/LICENSE does not exists}
  end

  specify 'displays a warning if no package managers are active/installed' do
    developer.create_empty_project
    developer.execute_command('license_finder')
    expect(developer).to be_seeing('No active and installed package managers found for project.')
    expect(developer).to be_receiving_exit_code(0)
  end

  context 'running action_items --recursive' do
    let(:action_items) { 'license_finder action_items --recursive' }
    let(:action_items_prepare) { 'license_finder action_items --prepare --recursive' }
    let(:permitted_licenses) { 'license_finder permitted_licenses add MIT' }
    let(:approvals) { 'license_finder approvals add objenesis' }
    let(:relative_decisions_path) { ' --decisions-file=folder-name/dependency_decisions.yml' }
    let(:absolute_decisions_path) { ' --decisions-file=/folder-name/dependency_decisions.yml' }

    before do
      LicenseFinder::TestingDSL::CompositeProject.create
      developer.execute_command(action_items_prepare)
    end

    specify 'uses default decisions-file' do
      developer.execute_command(permitted_licenses)
      developer.execute_command(approvals)
      developer.execute_command(action_items)
      expect(developer).to_not be_seeing('objenesis')
      expect(developer).to_not be_seeing('MIT')
    end

    specify 'uses decisions-file with relative path' do
      developer.execute_command(permitted_licenses + relative_decisions_path)
      developer.execute_command(approvals + relative_decisions_path)
      developer.execute_command(action_items + relative_decisions_path)
      expect(developer).to_not be_seeing('objenesis')
      expect(developer).to_not be_seeing('MIT')
    end

    specify 'uses decisions-file with absolute path' do
      developer.execute_command(permitted_licenses + absolute_decisions_path)
      developer.execute_command(approvals + absolute_decisions_path)
      developer.execute_command(action_items + absolute_decisions_path)
      expect(developer).to_not be_seeing('objenesis')
      expect(developer).to_not be_seeing('MIT')
    end
  end

  describe 'running project_roots' do
    context 'with --recursive flag' do
      context 'when called in root project' do
        let(:license_finder_command) { 'license_finder project_roots --recursive' }

        before do
          @project = LicenseFinder::TestingDSL::GradleProject::MultiModule.create
        end

        it 'returns all project paths excluding subprojects' do
          developer.execute_command(license_finder_command)

          expect(developer).to be_seeing_something_like %r{"#{Regexp.escape(@project.project_dir.to_s)}/multi-module-gradle"}
          expect(developer).to_not be_seeing_something_like %r{"#{Regexp.escape(@project.project_dir.to_s)}/multi-module-gradle/module1"}
          expect(developer).to_not be_seeing_something_like %r{"#{Regexp.escape(@project.project_dir.to_s)}/multi-module-gradle/module2"}
          expect(developer).to_not be_seeing_something_like %r{"#{Regexp.escape(@project.project_dir.to_s)}/multi-module-gradle/module3"}
          expect(developer).to be_seeing_something_like %r{"#{Regexp.escape(@project.project_dir.to_s)}/multi-module-gradle/module1/module4/src/github.com/pivotal/foo"}
        end
      end

      context 'when called in subproject directory' do
        let(:license_finder_command) { "license_finder project_roots --project_path=#{@project.project_dir}/multi-module-gradle/module1 --recursive" }

        before do
          @project = LicenseFinder::TestingDSL::GradleProject::MultiModule.create
        end

        it 'returns all project paths excluding subprojects including current directory' do
          developer.execute_command(license_finder_command)

          expect(developer).to be_seeing_something_like %r{"#{Regexp.escape(@project.project_dir.to_s)}/multi-module-gradle/module1"}
          expect(developer).to_not be_seeing_something_like %r{"#{Regexp.escape(@project.project_dir.to_s)}/multi-module-gradle/module3"}
          expect(developer).to be_seeing_something_like %r{"#{Regexp.escape(@project.project_dir.to_s)}/multi-module-gradle/module1/module4/src/github.com/pivotal/foo"}
        end
      end
    end

    context 'without flags' do
      let(:license_finder_command) { 'license_finder project_roots' }

      before do
        @project = LicenseFinder::TestingDSL::CompositeProject.create
      end

      specify 'returns current path' do
        developer.execute_command(license_finder_command)
        expect(developer).to be_seeing_something_like /^\["#{Regexp.escape(@project.project_dir.to_s)}"\]\n$/
      end
    end
  end
end
