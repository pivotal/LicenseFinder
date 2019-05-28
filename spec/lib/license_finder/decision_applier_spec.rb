# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe DecisionApplier do
    it 'reports nothing found' do
      decision_applier = described_class.new(
        decisions: Decisions.new,
        packages: []
      )
      expect(decision_applier.any_packages?).to be false
    end

    describe '#acknowledged' do
      it 'combines manual and system packages' do
        decision_applier = described_class.new(
          decisions: Decisions.new.add_package('manual', nil),
          packages: [Package.new('system')]
        )
        expect(decision_applier.acknowledged.map(&:name)).to match_array %w[manual system]
      end

      it 'applies decided licenses' do
        decisions = Decisions.new
                             .add_package('manual', nil)
                             .license('manual', 'MIT')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        expect(decision_applier.acknowledged.last.licenses).to eq Set.new([License.find_by_name('MIT')])
      end

      it 'applies decided homepage' do
        decisions = Decisions.new
                      .add_package('manual', nil)
                      .homepage('manual', 'some-homepage')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        expect(decision_applier.acknowledged.last.homepage).to eq 'some-homepage'
      end

      it 'ignores specific packages' do
        decisions = Decisions.new
                             .add_package('manual', nil)
                             .ignore('manual')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        expect(decision_applier.acknowledged).to be_empty
      end

      it 'ignores packages in certain groups' do
        decisions = Decisions.new
                             .ignore_group('development')
        dev_dep = Package.new('dep', nil, groups: ['development'])
        decision_applier = described_class.new(
          decisions: decisions,
          packages: [dev_dep]
        )
        expect(decision_applier.acknowledged).to be_empty
      end

      it 'does not ignore packages if some of their groups are not ignored' do
        decisions = Decisions.new
                             .ignore_group('development')
        dev_and_prod_dep = Package.new('dev_and_prod_dep', nil, groups: %w[development production])
        decision_applier = described_class.new(
          decisions: decisions,
          packages: [dev_and_prod_dep]
        )
        expect(decision_applier.acknowledged).to eq [dev_and_prod_dep]
      end

      it 'does not ignore packages if they have no groups' do
        decisions = Decisions.new
                             .ignore_group('development')
        dep_with_no_group = Package.new('dep_with_no_group', nil, groups: [])
        decision_applier = described_class.new(
          decisions: decisions,
          packages: [dep_with_no_group]
        )
        expect(decision_applier.acknowledged).to eq [dep_with_no_group]
      end

      it 'adds manual approvals to packages' do
        decisions = Decisions.new
                             .add_package('manual', nil)
                             .approve('manual', who: 'Approver', why: 'Because')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_approved_manually
        expect(dep.manual_approval.who).to eq 'Approver'
        expect(dep.manual_approval.why).to eq 'Because'
      end

      it 'adds whitelist approvals to packages' do
        decisions = Decisions.new
                             .add_package('manual', nil)
                             .license('manual', 'MIT')
                             .whitelist('MIT')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_whitelisted
      end

      it 'forbids approval of packages with only blacklisted license' do
        decisions = Decisions.new
                             .add_package('manual', nil)
                             .license('manual', 'ABC')
                             .whitelist('ABC')
                             .approve('manual')
                             .blacklist('ABC')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).not_to be_approved
      end

      it 'allows approval of packages if not all licenses are blacklisted' do
        decisions = Decisions.new
                             .add_package('manual', nil)
                             .license('manual', 'ABC')
                             .license('manual', 'DEF')
                             .whitelist('ABC')
                             .blacklist('DEF')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_whitelisted

        decisions = Decisions.new
                             .add_package('manual', nil)
                             .license('manual', 'ABC')
                             .license('manual', 'DEF')
                             .approve('manual')
                             .blacklist('DEF')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_approved_manually
      end

      it 'does not return an approval for a package without a version if all approvals have an explicit version' do
        decisions = Decisions.new
                             .add_package('spring-boot', nil)
                             .approve('spring-boot', versions: ['1.3.0.RELEASE'], who: 'Approver', why: 'Because')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to_not be_approved
      end

      it 'does not return an approval if the package has the wrong version' do
        decisions = Decisions.new
                             .add_package('spring-boot', '1.3.1.RELEASE')
                             .approve('spring-boot', versions: ['1.3.0.RELEASE'], who: 'Approver', why: 'Because')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to_not be_approved
      end

      it 'returns an approval if the requested package has an approved version' do
        decisions = Decisions.new
                             .add_package('spring-boot', '1.3.0.RELEASE')
                             .approve('spring-boot', versions: ['1.3.0.RELEASE'], who: 'Approver', why: 'Because')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_approved_manually
      end

      it 'returns an approval if the requested package has been approved, but no version was specified' do
        decisions = Decisions.new
                             .add_package('spring-boot', '1.3.0.RELEASE')
                             .approve('spring-boot', versions: [], who: 'Approver', why: 'Because')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to be_approved
        expect(dep).to be_approved_manually
      end

      it 'does not return an approval if no dependencies have been approved' do
        decisions = Decisions.new
                             .add_package('spring-boot', '1.3.0.RELEASE')
        decision_applier = described_class.new(decisions: decisions, packages: [])
        dep = decision_applier.acknowledged.last
        expect(dep).to_not be_approved
      end
    end

    describe '#unapproved' do
      it 'returns all acknowledged packages that are not approved' do
        packages = [
          Package.new('foo', '0.0.1', spec_licenses: ['whitelist']),
          Package.new('bar', '0.0.1', spec_licenses: ['blacklist'])
        ]
        decisions = Decisions.new
                             .add_package('baz', '0.0.1')
                             .whitelist('whitelist')
                             .blacklist('blacklist')
        decision_applier = described_class.new(decisions: decisions, packages: packages)

        expect(decision_applier.unapproved.map(&:name)).to include('baz')
        expect(decision_applier.unapproved.map(&:name)).to include('bar')
        expect(decision_applier.unapproved.map(&:name)).not_to include('foo')
      end
    end

    describe '#blacklisted' do
      it 'returns all packages that have blacklisted licenses' do
        decision_applier = described_class.new(
          decisions: Decisions.new.blacklist('GPLv3'),
          packages: [Package.new('foo', '1.0', spec_licenses: ['GPLv3'])]
        )

        expect(decision_applier.blacklisted.map(&:name)).to eq(['foo'])
      end

      it 'does not report ignored packages' do
        dev_dep = Package.new('dev_dep', nil, spec_licenses: ['GPLv3'], groups: ['development'])
        decisions = Decisions.new
                             .ignore_group('development')
                             .add_package('manual', nil)
                             .ignore('manual')
                             .blacklist('GPLv3')
        decision_applier = described_class.new(decisions: decisions, packages: [dev_dep])

        expect(decision_applier.blacklisted).to be_empty
      end
    end
  end
end
