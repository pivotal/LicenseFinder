# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe MarkdownReport do
    describe '#to_s' do
      let(:dep1) do
        Package.new('gem_a', '1.0')
      end

      let(:dep2) do
        result = Package.new('gem_b', '2.3')
        result.decide_on_license(License.find_by_name('BSD'))
        result.approved_manually!(double(:approval).as_null_object)
        result
      end
      let(:dependencies) { [dep2, dep1] }

      subject { MarkdownReport.new(dependencies, project_name: 'new_project_name').to_s }

      it 'should not show the paths section' do
        is_expected.not_to match 'Paths'
      end

      context 'when the dependency is a merged package' do
        context 'when there is at least one aggregate path' do
          let(:merged_dependency) do
            dep = MergedPackage.new(dep1, %w[path1 path2])
            dep.decide_on_license License.find_by_name('MIT')
            dep
          end
          let(:dependencies) { [merged_dependency] }
          it 'should show each of the aggregate paths' do
            is_expected.to match 'Paths'
            is_expected.to match 'path1'
            is_expected.to match 'path2'
          end
        end
        context 'when there are no aggregate paths' do
          let(:merged_dependency) do
            dep = MergedPackage.new(dep1, [])
            dep.decide_on_license License.find_by_name('MIT')
            dep
          end
          let(:dependencies) { [merged_dependency] }
          it 'should not show the paths section' do
            is_expected.not_to match 'Paths'
          end
        end
      end

      it 'should have the correct header' do
        is_expected.to match '# new_project_name'
      end

      it 'should list the total, and unapproved counts' do
        is_expected.to match '2 total'
        is_expected.to match /1 \*unapproved\*/
      end

      it 'should list the unapproved dependency' do
        is_expected.to match 'href="#gem_a"'
      end

      it 'should display a summary' do
        is_expected.to match '## Summary'
        is_expected.to match /\s+\* 1 unknown/
        is_expected.to match /\s+\* 1 BSD/
      end

      it 'should list both gems' do
        is_expected.to match '## Items'
        is_expected.to match '### gem_a v1.0'
        is_expected.to match '### gem_b v2.3'
      end
    end
  end
end
