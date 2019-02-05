# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Diff report' do
  # As a non-technical product owner
  # I want to see the differences between two reports
  # So that I can easily review what changed between versions

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  context 'single project reports' do
    specify 'shows differences between two csv reports' do
      project = developer.create_ruby_app
      project.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
      developer.execute_command('license_finder report --save=report-1.csv --format=csv')

      project.depend_on(developer.create_gem('bar', version: '2.0.0', license: 'GPLv2'))
      developer.execute_command('license_finder report --save=report-2.csv --format=csv')

      developer.execute_command('license_finder diff report-1.csv report-2.csv')

      expect(developer).to be_seeing('added,bar,2.0.0,GPLv2')
      expect(developer).to be_seeing('unchanged,foo,1.0.0,MIT')
    end

    specify 'shows version changes between two csv reports' do
      project = developer.create_ruby_app
      project.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
      developer.execute_command('license_finder report --save=report-1.csv --format=csv')

      project.depend_on(developer.create_gem('foo', version: '2.0.0', license: 'MIT'))
      developer.execute_command('license_finder report --save=report-2.csv --format=csv')

      developer.execute_command('license_finder diff report-1.csv report-2.csv')
      expect(developer).to be_seeing('added,foo,2.0.0,MIT')
      expect(developer).to be_seeing('removed,foo,1.0.0,MIT')
    end

    specify 'shows license changes between two csv reports' do
      project = developer.create_ruby_app
      project.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
      developer.execute_command('license_finder report --save=report-1.csv --format=csv')

      project.depend_on(developer.create_gem('foo', version: '2.0.0', license: 'GPLv2'))
      developer.execute_command('license_finder report --save=report-2.csv --format=csv')

      developer.execute_command('license_finder diff report-1.csv report-2.csv')
      expect(developer).to be_seeing('removed,foo,1.0.0,MIT')
      expect(developer).to be_seeing('added,foo,2.0.0,GPLv2')
    end
  end

  context 'multi-project reports' do
    specify 'shows differences between two csv reports' do
      project = developer.create_empty_project

      # First multi-project report
      project1 = developer.create_ruby_app('project_1')
      project1.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
      project1.depend_on(developer.create_gem('bar', version: '2.0.0', license: 'GPLv2'))

      project2 = developer.create_ruby_app('project_2')
      project2.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
      developer
        .execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-1.csv --format=csv")

      # Second multi-project report
      project2.depend_on(developer.create_gem('baz', version: '3.0.0', license: 'BSD'))
      developer
        .execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-2.csv --format=csv")

      # Diff the reports
      developer.execute_command('license_finder diff report-1.csv report-2.csv --save=diff.csv --format=csv')

      diff = IO.read(project.project_dir.join('diff.csv'))
      expect(diff).to include("unchanged,foo,1.0.0,MIT,\"#{project1.project_dir},#{project2.project_dir}\"")
      expect(diff).to include("unchanged,bar,2.0.0,GPLv2,#{project1.project_dir}")
      expect(diff).to include("added,baz,3.0.0,BSD,#{project2.project_dir}")
    end

    context 'when change affects only one file' do
      specify 'show version changes' do
        project = developer.create_empty_project
        # First multi-project report
        project1 = developer.create_ruby_app('project_1')
        project1.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
        project1.depend_on(developer.create_gem('bar', version: '2.0.0', license: 'GPLv2'))

        project2 = developer.create_ruby_app('project_2')
        project2.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
        developer
          .execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-1.csv --format=csv")

        # Second multi-project report
        project2.depend_on(developer.create_gem('baz', version: '3.0.0', license: 'BSD'))
        project1.depend_on(developer.create_gem('bar', version: '3.0.0', license: 'GPLv2'))

        developer
          .execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-2.csv --format=csv")

        # Diff the reports
        developer.execute_command('license_finder diff report-1.csv report-2.csv --save=diff.csv --format=csv')

        diff = IO.read(project.project_dir.join('diff.csv'))
        expect(diff).to include("unchanged,foo,1.0.0,MIT,\"#{project1.project_dir},#{project2.project_dir}\"")
        expect(diff).to include("added,bar,3.0.0,GPLv2,#{project1.project_dir}")
        expect(diff).to include("removed,bar,2.0.0,GPLv2,#{project1.project_dir}")
        expect(diff).to include("added,baz,3.0.0,BSD,#{project2.project_dir}")
      end

      specify 'shows license changes' do
        project = developer.create_empty_project
        # First multi-project report
        project1 = developer.create_ruby_app('project_1')
        project1.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
        project1.depend_on(developer.create_gem('bar', version: '2.0.0', license: 'GPLv2'))

        project2 = developer.create_ruby_app('project_2')
        project2.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
        developer
          .execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-1.csv --format=csv")

        # Second multi-project report
        project2.depend_on(developer.create_gem('baz', version: '3.0.0', license: 'BSD'))
        project1.depend_on(developer.create_gem('bar', version: '3.0.0', license: 'MIT'))

        developer
          .execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-2.csv --format=csv")

        # Diff the reports
        developer
          .execute_command('license_finder diff report-1.csv report-2.csv --save=diff.csv --format=csv')

        diff = IO.read(project.project_dir.join('diff.csv'))
        expect(diff).to include("unchanged,foo,1.0.0,MIT,\"#{project1.project_dir},#{project2.project_dir}\"")
        expect(diff).to include("removed,bar,2.0.0,GPLv2,#{project1.project_dir}")
        expect(diff).to include("added,bar,3.0.0,MIT,#{project1.project_dir}")
        expect(diff).to include("added,baz,3.0.0,BSD,#{project2.project_dir}")
      end
    end

    context 'when change affects both files' do
      specify 'show licenses change when files contain exact copies of a dep' do
        project = developer.create_empty_project
        # First multi-project report
        project1 = developer.create_ruby_app('project_1')
        project1.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
        project1.depend_on(developer.create_gem('bar', version: '2.0.0', license: 'GPLv2'))

        project2 = developer.create_ruby_app('project_2')
        project2.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
        developer
          .execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-1.csv --format=csv")

        # Second multi-project report
        project2.depend_on(developer.create_gem('baz', version: '3.0.0', license: 'BSD'))
        project1.depend_on(developer.create_gem('foo', version: '2.0.0', license: 'BSD'))

        developer
          .execute_command("license_finder report --columns name version licenses aggregate_paths --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-2.csv --format=csv")

        # Diff the reports
        developer
          .execute_command('license_finder diff report-1.csv report-2.csv --save=diff.csv --format=csv')

        diff = IO.read(project.project_dir.join('diff.csv'))
        expect(diff).to include("unchanged,bar,2.0.0,GPLv2,#{project1.project_dir}")
        expect(diff).to include("removed,foo,1.0.0,MIT,\"#{project1.project_dir},#{project2.project_dir}\"")
        expect(diff).to include("added,foo,2.0.0,BSD,\"#{project1.project_dir},#{project2.project_dir}\"")
        expect(diff).to include("added,baz,3.0.0,BSD,#{project2.project_dir}")
      end

      xspecify 'show licenses change when files do not contain exact copies of a dep' do
        project = developer.create_empty_project
        # First multi-project report
        project1 = developer.create_ruby_app('project_1')
        project1.depend_on(developer.create_gem('foo', version: '1.0.0', license: 'MIT'))
        project1.depend_on(developer.create_gem('bar', version: '2.0.0', license: 'GPLv2'))

        project2 = developer.create_ruby_app('project_2')
        project2.depend_on(developer.create_gem('foo', version: '2.0.0', license: 'BSD'))
        developer.execute_command("license_finder report --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-1.csv --format=csv")

        # Second multi-project report
        project2.depend_on(developer.create_gem('baz', version: '3.0.0', license: 'BSD'))
        project1.depend_on(developer.create_gem('foo', version: '2.0.0', license: 'BSD'))

        developer.execute_command("license_finder report --aggregate_paths=#{project1.project_dir} #{project2.project_dir} --save=report-2.csv --format=csv")

        # Diff the reports
        developer.execute_command('license_finder diff report-1.csv report-2.csv --save=diff.csv --format=csv')

        diff = IO.read(project.project_dir.join('diff.csv'))
        expect(diff).to include("removed,foo,1.0.0,MIT,#{project1.project_dir}")
        # expect(diff).to include("removed,foo,,2.0.0,BSD,#{project2.project_dir}")
        expect(diff).to include("added,foo,2.0.0,BSD,\"#{project1.project_dir},#{project2.project_dir}\"")
        expect(diff).to include("removed,foo,1.0.0,BSD,\"#{project1.project_dir},#{project2.project_dir}\"")

        expect(diff).to include("unchanged,bar,2.0.0,GPLv2,#{project1.project_dir}")
        expect(diff).to include("added,baz,3.0.0,BSD,#{project2.project_dir}")
      end
    end
  end
end
