# frozen_string_literal: true

require 'spec_helper'
require 'capybara'

module LicenseFinder
  describe HtmlReport do
    describe '#to_s' do
      let(:dependency) do
        dep = Package.new('the-dep')
        dep.decide_on_license License.find_by_name('MIT')
        dep
      end
      let(:dependencies) { [dependency] }

      subject { Capybara.string(HtmlReport.new(dependencies, project_name: 'project name').to_s) }

      it 'should show the project name' do
        title = subject.find 'h1'
        expect(title).to have_text 'project name'
      end

      it 'should not show the paths section' do
        is_expected.not_to have_text 'Paths'
      end

      context 'when the dependency is a merged package' do
        context 'when there is at least one aggregate path' do
          let(:merged_dependency) do
            dep = MergedPackage.new(dependency, %w[path1 path2])
            dep.decide_on_license License.find_by_name('MIT')
            dep
          end
          let(:dependencies) { [merged_dependency] }
          it 'should show each of the aggregate paths' do
            is_expected.to have_text 'Paths'
            is_expected.to have_text 'path1'
            is_expected.to have_text 'path2'
          end
        end
        context 'when there are no aggregate paths' do
          let(:merged_dependency) do
            dep = MergedPackage.new(dependency, [])
            dep.decide_on_license License.find_by_name('MIT')
            dep
          end
          let(:dependencies) { [merged_dependency] }
          it 'should not show the paths section' do
            is_expected.not_to have_text 'Paths'
          end
        end
      end

      context 'when the dependency is manually approved' do
        before { dependency.approved_manually!(Decisions::TXN.new('the-approver', 'the-approval-note', Time.now.utc)) }

        it 'should show approved dependencies without action items' do
          is_expected.to have_selector '.approved'
          is_expected.not_to have_selector '.action-items'
        end

        it 'shows the license, approver and approval notes' do
          deps = subject.find '.dependencies'
          expect(deps).to have_content 'MIT'
          expect(deps).to have_content 'the-approver'
          expect(deps).to have_content 'the-approval-note'
          expect(deps).to have_selector 'time'
        end
      end

      context 'when the dependency is whitelisted' do
        before { dependency.whitelisted! }

        it 'should show approved dependencies without action items' do
          is_expected.to have_selector '.approved'
          is_expected.not_to have_selector '.action-items'
        end

        it 'shows the license' do
          deps = subject.find '.dependencies'
          expect(deps).to have_content 'MIT'
        end
      end

      context 'when the dependency is not approved' do
        it 'should show unapproved dependencies with action items' do
          is_expected.to have_selector '.unapproved'
          is_expected.to have_selector '.action-items li'
        end
      end

      context 'when the gem has a group' do
        let(:dependency) do
          Package.new(nil, nil, groups: ['foo group'])
        end

        it 'should show the group' do
          is_expected.to have_text '(foo group)'
        end
      end

      context 'when the gem does not have a group' do
        it 'should not show the group' do
          is_expected.not_to have_text '()'
        end
      end

      context 'when the gem has many relationships' do
        let(:dependencies) do
          grandparent = Package.new('foo grandparent', nil, children: ['foo parent'])
          parent      = Package.new('foo parent',      nil, children: ['foo child'])
          child       = Package.new('foo child')
          pm = PackageManager.new
          allow(pm).to receive(:current_packages) { [grandparent, parent, child] }
          pm.current_packages_with_relations
        end

        it 'should show the relationships' do
          is_expected.to have_text 'foo parent is required by:'
          is_expected.to have_text 'foo grandparent'
          is_expected.to have_text 'foo parent relies on:'
          is_expected.to have_text 'foo child'
        end
      end

      context 'when the gem has no relationships' do
        it 'should not show any relationships' do
          is_expected.not_to have_text 'is required by:'
          is_expected.not_to have_text 'relies on:'
        end
      end
    end
  end
end
