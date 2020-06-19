# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Decisions do
    describe '.add_package' do
      it 'adds to list of packages' do
        packages = subject.add_package('dep', nil).packages
        expect(packages.map(&:name)).to eq ['dep']
      end

      it 'includes optional version' do
        packages = subject.add_package('dep', '0.2.0').packages
        expect(packages.first.version).to eq '0.2.0'
      end
    end

    describe '.remove_package' do
      it 'drops a package' do
        packages = subject
                   .add_package('dep', nil)
                   .remove_package('dep')
                   .packages
        expect(packages.size).to eq 0
      end

      it 'does nothing if package was never added' do
        packages = subject
                   .remove_package('dep')
                   .packages
        expect(packages.size).to eq 0
      end
    end

    describe '.license' do
      it 'will report license for a dependency' do
        license = subject
                  .license('dep', 'MIT')
                  .licenses_of('dep')
                  .first
        expect(license).to eq License.find_by_name('MIT')
      end

      it 'will report multiple licenses' do
        licenses = subject
                   .license('dep', 'MIT')
                   .license('dep', 'GPL')
                   .licenses_of('dep')
        expect(licenses).to eq [
          License.find_by_name('MIT'),
          License.find_by_name('GPL')
        ].to_set
      end

      it 'adapts names' do
        license = subject
                  .license('dep', 'Expat')
                  .licenses_of('dep')
                  .first
        expect(license).to eq License.find_by_name('MIT')
      end
    end

    describe '.unlicense' do
      it 'will not report the given dependency as licensed' do
        licenses = subject
                   .license('dep', 'MIT')
                   .unlicense('dep', 'MIT')
                   .licenses_of('dep')
        expect(licenses).to be_empty
      end

      it 'will only remove the specified license' do
        licenses = subject
                   .license('dep', 'MIT')
                   .license('dep', 'GPL')
                   .unlicense('dep', 'MIT')
                   .licenses_of('dep')
        expect(licenses).to eq [License.find_by_name('GPL')].to_set
      end

      it 'is cumulative' do
        license = subject
                  .license('dep', 'MIT')
                  .unlicense('dep', 'MIT')
                  .license('dep', 'MIT')
                  .licenses_of('dep')
                  .first
        expect(license).to eq License.find_by_name('MIT')
      end
    end

    describe '.homepage' do
      it 'will report homepage for a dependency' do
        homepage = subject
                     .homepage('dep', 'home-page/dep')
                     .homepage_of('dep')
        expect(homepage).to eq 'home-page/dep'
      end

      it 'will report overwritten homepages' do
        homepages = subject
                      .homepage('dep', 'home-page/dep')
                      .homepage('dep', 'other-page/dep')
                      .homepage_of('dep')
        expect(homepages).to eq 'other-page/dep'
      end
    end

    describe '.approve' do
      it 'will report a dependency as approved' do
        decisions = subject.approve('dep')
        expect(decisions).to be_approved('dep')
      end

      it 'will not report a dependency as approved by default' do
        expect(subject).not_to be_approved('dep')
      end
    end

    describe '.unapprove' do
      it 'will not report the given dependency as approved' do
        subject.approve('dep')
               .unapprove('dep')
        expect(subject).not_to be_approved('dep')
      end

      it 'is cumulative' do
        subject.approve('dep')
               .unapprove('dep')
               .approve('dep')
        expect(subject).to be_approved('dep')
      end
    end

    describe '.permit' do
      it 'will report the given license as permitted' do
        decisions = subject.permit('MIT')
        expect(decisions).to be_permitted(License.find_by_name('MIT'))
      end

      it 'adapts names' do
        decisions = subject.permit('Expat')
        expect(decisions).to be_permitted(License.find_by_name('MIT'))
      end

      it 'adds to list' do
        decisions = subject.permit('MIT')
        expect(decisions.permitted).to eq(Set.new([License.find_by_name('MIT')]))
      end
    end

    describe '.unpermit' do
      it 'will not report the given license as permitted' do
        decisions = subject
                    .permit('MIT')
                    .unpermit('MIT')
        expect(decisions).not_to be_permitted(License.find_by_name('MIT'))
      end

      it 'is cumulative' do
        decisions = subject
                    .permit('MIT')
                    .unpermit('MIT')
                    .permit('MIT')
        expect(decisions).to be_permitted(License.find_by_name('MIT'))
      end

      it 'adapts names' do
        decisions = subject
                    .permit('MIT')
                    .unpermit('Expat')
        expect(decisions).not_to be_permitted(License.find_by_name('MIT'))
      end
    end

    describe '.restrict' do
      it 'will report the given license as restricted' do
        decisions = subject.restrict('MIT')
        expect(decisions).to be_restricted(License.find_by_name('MIT'))
      end

      it 'adapts names' do
        decisions = subject.restrict('Expat')
        expect(decisions).to be_restricted(License.find_by_name('MIT'))
      end

      it 'adds to list' do
        decisions = subject.restrict('MIT')
        expect(decisions.restricted).to eq(Set.new([License.find_by_name('MIT')]))
      end
    end

    describe '.unrestrict' do
      it 'will not report the given license as restricted' do
        decisions = subject
                    .restrict('MIT')
                    .unrestrict('MIT')
        expect(decisions).not_to be_restricted(License.find_by_name('MIT'))
      end

      it 'is cumulative' do
        decisions = subject
                    .restrict('MIT')
                    .unrestrict('MIT')
                    .restrict('MIT')
        expect(decisions).to be_restricted(License.find_by_name('MIT'))
      end

      it 'adapts names' do
        decisions = subject
                    .restrict('MIT')
                    .unrestrict('Expat')
        expect(decisions).not_to be_restricted(License.find_by_name('MIT'))
      end
    end

    describe '.ignore' do
      it 'will report ignored dependencies' do
        decisions = subject.ignore('dep')
        expect(decisions).to be_ignored('dep')
      end
    end

    describe '.heed' do
      it 'will not report heeded dependencies' do
        decisions = subject
                    .ignore('dep')
                    .heed('dep')
        expect(decisions).not_to be_ignored('dep')
      end

      it 'is cumulative' do
        decisions = subject
                    .ignore('dep')
                    .heed('dep')
                    .ignore('dep')
        expect(decisions).to be_ignored('dep')
      end
    end

    describe '.ignore_group' do
      it 'will report ignored groups' do
        decisions = subject.ignore_group('development')
        expect(decisions).to be_ignored_group('development')
      end
    end

    describe '.heed_group' do
      it 'will not report heeded groups' do
        decisions = subject
                    .ignore_group('development')
                    .heed_group('development')
        expect(decisions).not_to be_ignored_group('development')
      end

      it 'is cumulative' do
        decisions = subject
                    .ignore_group('development')
                    .heed_group('development')
                    .ignore_group('development')
        expect(decisions).to be_ignored_group('development')
      end
    end

    describe '.name_project' do
      it 'reports project name' do
        decisions = subject.name_project('proj')
        expect(decisions.project_name).to eq 'proj'
      end
    end

    describe '.unname_project' do
      it 'reports project name' do
        decisions = subject
                    .name_project('proj')
                    .unname_project
        expect(decisions.project_name).to be_nil
      end
    end

    describe '.inherit_from' do
      let(:yml) { YAML.dump([[:permit, 'MIT']]) }

      it 'inheritates rules from local decision file' do
        allow_any_instance_of(Pathname).to receive(:read).and_return(yml)
        decisions = subject.inherit_from('./config/inherit.yml')
        expect(decisions).to be_permitted(License.find_by_name('MIT'))
      end

      it 'inheritates rules from remote decision file' do
        stub_request(:get, 'https://example.com/config/inherit.yml').to_return(status: 200, body: yml, headers: {})
        decisions = subject.inherit_from('https://example.com/config/inherit.yml')
        expect(decisions).to be_permitted(License.find_by_name('MIT'))
      end

      it 'inheritates rules from remote decision file with new config format' do
        stub_request(:get, 'https://example.com/config/inherit.yml').to_return(status: 200, body: yml, headers: {})
        decisions = subject.inherit_from({ 'url' => 'https://example.com/config/inherit.yml' })
        expect(decisions).to be_permitted(License.find_by_name('MIT'))
      end

      it 'inheritates rules from a private remote decision file' do
        stub_request(:get, 'https://example.com/config/inherit.yml')
          .with(headers: { 'Authorization' => 'Bearer Token' })
          .to_return(status: 200, body: yml, headers: {})
        decisions = subject.inherit_from({ 'url' => 'https://example.com/config/inherit.yml', 'token' => 'Token' })
        expect(decisions).to be_permitted(License.find_by_name('MIT'))
      end

      it 'inheritates rules from a private remote decision file with token in an env variable' do
        allow(ENV).to receive(:fetch).with('TOKEN_ENV', nil).and_return('Token')

        stub_request(:get, 'https://example.com/config/inherit.yml')
          .with(headers: { 'Authorization' => 'Bearer Token' })
          .to_return(status: 200, body: yml, headers: {})

        decisions = subject.inherit_from({ 'url' => 'https://example.com/config/inherit.yml', 'token' => '$TOKEN_ENV' })
        expect(decisions).to be_permitted(License.find_by_name('MIT'))
      end
    end

    describe '.remove_inheritance' do
      it 'reports inheritanced decisions' do
        allow_any_instance_of(Pathname).to receive(:read).and_return('---')
        decisions = subject.inherit_from('./config/inherit.yml')
        expect(decisions.inherited_decisions).to include('./config/inherit.yml')

        decisions = subject.remove_inheritance('./config/inherit.yml')
        expect(decisions.inherited_decisions).to be_empty
      end
    end

    describe 'persistence' do
      def roundtrip(decisions)
        described_class.restore(decisions.persist)
      end

      it 'can restore added packages' do
        decisions = roundtrip(
          subject.add_package('dep', '0.2.0')
        )
        packages = decisions.packages
        expect(packages.map(&:name)).to eq ['dep']
      end

      it 'can restore removed packages' do
        decisions = roundtrip(
          subject
            .add_package('dep', nil)
            .remove_package('dep')
        )
        expect(decisions.packages.size).to eq 0
      end

      it 'can restore licenses' do
        license = roundtrip(
          subject.license('dep', 'MIT')
        ).licenses_of('dep').first
        expect(license).to eq License.find_by_name('MIT')
      end

      it 'can restore unlicenses' do
        licenses = roundtrip(
          subject
            .license('dep', 'MIT')
            .license('dep', 'GPL')
            .unlicense('dep', 'MIT')
        ).licenses_of('dep')
        expect(licenses).to eq [License.find_by_name('GPL')].to_set
      end

      it 'can restore homepage' do
        homepage = roundtrip(
          subject.homepage('dep', 'home-page/dep')
        ).homepage_of('dep')
        expect(homepage).to eq 'home-page/dep'
      end

      it 'can restore overwritten homepages' do
        homepage = roundtrip(
          subject
            .homepage('dep', 'home-page/dep')
            .homepage('dep', 'other-page/dep')
        ).homepage_of('dep')
        expect(homepage).to eq 'other-page/dep'
      end

      it 'can restore approvals without versions' do
        time = Time.now.getutc
        roundtrip(subject.approve('dep', who: 'Somebody', why: 'Some reason', when: time))

        approval = subject.approval_of('dep')
        expect(approval.who).to eq 'Somebody'
        expect(approval.why).to eq 'Some reason'
        expect(approval.safe_when).to eq time
        expect(approval.safe_versions).to eq []
      end

      it 'can restore approvals with versions' do
        time = Time.now.getutc
        roundtrip(subject.approve('dep', who: 'Somebody', why: 'Some reason', when: time, versions: ['1.0']))
        roundtrip(subject.approve('dep', who: 'Somebody', why: 'Some reason', when: time, versions: ['2.0']))
        roundtrip(subject.approve('dep', who: 'Somebody', why: 'Some reason', when: time, versions: ['3.0']))

        approval = subject.approval_of('dep', '1.0')
        expect(approval.who).to eq 'Somebody'
        expect(approval.why).to eq 'Some reason'
        expect(approval.safe_when).to eq time
        expect(approval.safe_versions).to eq ['1.0', '2.0', '3.0']
      end

      it 'can restore unapprovals' do
        decisions = roundtrip(
          subject
            .approve('dep')
            .unapprove('dep')
        )
        expect(decisions).not_to be_approved('dep')
      end

      it 'can restore permitted licenses' do
        decisions = roundtrip(
          subject.permit('MIT')
        )
        expect(decisions).to be_permitted(License.find_by_name('MIT'))
      end

      it 'can restore un-permitted licenses' do
        decisions = roundtrip(
          subject
            .permit('MIT')
            .unpermit('MIT')
        )
        expect(decisions).not_to be_permitted(License.find_by_name('MIT'))
      end

      it 'can restore restricted licenses' do
        decisions = roundtrip(
          subject.restrict('MIT')
        )
        expect(decisions).to be_restricted(License.find_by_name('MIT'))
      end

      it 'can restore un-restricted licenses' do
        decisions = roundtrip(
          subject
            .restrict('MIT')
            .unrestrict('MIT')
        )
        expect(decisions).not_to be_restricted(License.find_by_name('MIT'))
      end

      it 'can restore ignorals' do
        decisions = roundtrip(subject.ignore('dep'))
        expect(decisions).to be_ignored('dep')
      end

      it 'can restore heeds' do
        decisions = roundtrip(
          subject
            .ignore('dep')
            .heed('dep')
        )
        expect(decisions).not_to be_ignored('dep')
      end

      it 'can restore ignored groups' do
        decisions = roundtrip(
          subject.ignore_group('development')
        )
        expect(decisions).to be_ignored_group('development')
      end

      it 'can restore heeded groups' do
        decisions = roundtrip(
          subject
            .ignore_group('development')
            .heed_group('development')
        )
        expect(decisions).not_to be_ignored_group('development')
      end

      it 'can restore project names' do
        decisions = roundtrip(
          subject.name_project('an-app')
        )
        expect(decisions.project_name).to eq 'an-app'
      end

      it 'can restore project unnames' do
        decisions = roundtrip(
          subject
            .name_project('an-app')
            .unname_project
        )
        expect(decisions.project_name).to be_nil
      end

      it 'can restore inherited decisions' do
        allow_any_instance_of(Pathname).to receive(:read).and_return(YAML.dump([[:permit, 'MIT']]))
        decisions = roundtrip(
          subject
            .inherit_from('./config/inherit.yml')
        )
        expect(decisions.inherited_decisions).to include('./config/inherit.yml')
      end

      it 'does not store decisions from inheritance' do
        allow_any_instance_of(Pathname).to receive(:read).and_return(YAML.dump([[:permit, 'MIT']]))
        decisions = subject.inherit_from('./config/inherit.yml')
        expect(decisions.persist).to eql(YAML.dump([[:inherit_from, './config/inherit.yml']]))
      end

      it 'ignores empty or missing persisted decisions' do
        described_class.restore('')
        described_class.restore(nil)
      end
    end
  end
end
