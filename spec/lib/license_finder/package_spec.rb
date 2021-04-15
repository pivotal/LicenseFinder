# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Package do
    let(:logger) { double('Logger', info: nil, debug: nil) }
    subject do
      described_class.new(
        'a package',
        '1.3.1',
        authors: 'the authors',
        summary: 'a summary',
        description: 'a description',
        homepage: 'a homepage',
        package_url: 'a package_url',
        groups: %w[dev test],
        children: %w[child-1 child2],
        install_path: 'some/package/path',
        spec_licenses: %w[MIT GPL],
        logger: logger
      )
    end

    its(:name) { should == 'a package' }
    its(:version) { should == '1.3.1' }
    its(:authors) { should == 'the authors' }
    its(:summary) { should == 'a summary' }
    its(:description) { should == 'a description' }
    its(:homepage) { should == 'a homepage' }
    its(:package_url) { should == 'a package_url' }
    its(:groups) { should == %w[dev test] }
    its(:children) { should == %w[child-1 child2] }
    its(:install_path) { should eq 'some/package/path' }

    it 'has defaults' do
      subject = described_class.new(nil, nil)
      expect(subject.name).to be_nil
      expect(subject.version).to eq ''
      expect(subject.authors).to eq ''
      expect(subject.summary).to eq ''
      expect(subject.description).to eq ''
      expect(subject.homepage).to eq ''
      expect(subject.package_url).to eq ''
      expect(subject.groups).to eq []
      expect(subject.children).to eq []
      expect(subject.install_path).to be_nil
      expect(subject.license_names_from_spec).to eq []
      expect(subject.licenses.map(&:name)).to eq ['unknown']
    end

    describe '#licenses' do
      def stub_license_files(*license_names)
        license_files = license_names.map do |license_name|
          double(:file, license: License.find_by_name(license_name), path: 'some/path')
        end
        allow(LicenseFiles).to receive(:find).with('some/package/path', logger: logger)
                                             .and_return(license_files)
      end

      it 'are not required' do
        subject = described_class.new(nil, nil)
        expect(subject.licenses.map(&:name)).to eq ['unknown']
      end

      describe 'decided by user' do
        it 'returns all decided licenses' do
          subject = described_class.new(nil, nil)
          subject.decide_on_license(License.find_by_name('MIT'))
          subject.decide_on_license(License.find_by_name('GPL'))
          expect(subject.licenses.map(&:name)).to match_array %w[GPL MIT]
        end

        it 'de-duplicates across license aliases' do
          subject = described_class.new(nil, nil)
          subject.decide_on_license(License.find_by_name('MIT'))
          subject.decide_on_license(License.find_by_name('Expat'))
          expect(subject.licenses.map(&:name)).to eq ['MIT']
        end

        it 'trumps licenses from the spec' do
          subject = described_class.new(nil, nil, spec_licenses: ['GPL'])
          subject.decide_on_license(License.find_by_name('MIT'))
          expect(subject.licenses.map(&:name)).to eq ['MIT']
        end

        it 'trumps licenses from the install path' do
          stub_license_files 'Detected License'
          subject = described_class.new(nil, nil, install_path: 'some/package/path', logger: logger)
          subject.decide_on_license(License.find_by_name('MIT'))
          expect(subject.licenses.map(&:name)).to eq ['MIT']
        end
      end

      describe 'from the spec' do
        it 'converts the names to licenses' do
          subject = described_class.new(nil, nil, spec_licenses: %w[MIT GPL])
          expect(subject.licenses.map(&:name)).to match_array %w[GPL MIT]
        end

        it 'de-duplicates across license aliases' do
          subject = described_class.new(nil, nil, spec_licenses: %w[MIT Expat], logger: logger)
          expect(subject.licenses.map(&:name)).to eq ['MIT']
        end

        it 'trumps licenses from the install path' do
          stub_license_files 'Detected License'
          subject = described_class.new(nil, nil, spec_licenses: ['MIT'], install_path: 'some/package/path', logger: logger)
          expect(subject.licenses.map(&:name)).to eq ['MIT']
        end
      end

      describe 'from the install path' do
        it 'uses the licenses reported by files in the install path' do
          stub_license_files 'MIT', 'GPL'
          subject = described_class.new(nil, nil, install_path: 'some/package/path', logger: logger)
          expect(subject.licenses.map(&:name)).to eq %w[GPL MIT]
        end

        it 'de-duplicates across license aliases' do
          stub_license_files 'MIT', 'Expat'
          subject = described_class.new(nil, nil, install_path: 'some/package/path', logger: logger)
          expect(subject.licenses.map(&:name)).to eq ['MIT']
        end
      end
    end

    describe '#restricted?' do
      it 'defaults to false' do
        expect(subject.restricted?).to eq(false)
      end

      it 'can be set by restricted!' do
        subject.restricted!
        expect(subject.restricted?).to eq(true)
      end
    end

    describe '#approved?' do
      it 'returns false by default' do
        expect(subject.approved?).to eq(false)
      end

      it 'returns true when approved manually' do
        subject.approved_manually!('I approve of this dependency')
        expect(subject.approved?).to eq(true)
      end

      it 'returns true when permitted' do
        subject.permitted!
        expect(subject.approved?).to eq(true)
      end

      it 'returns false when restricted' do
        subject.restricted!
        expect(subject.approved?).to eq(false)
      end
    end

    describe '#eql?' do
      it 'returns true if package name matches' do
        p1 = Package.new('package', '0.0.1')
        p2 = Package.new('package', '0.0.1')
        p3 = Package.new('foo', 'foo')
        p4 = Package.new('foo', 'foo2')

        expect(p1.eql?(p2)).to be true
        expect(p1.eql?(p3)).to be false
        expect(p3.eql?(p4)).to be false

        expect(p1.hash).to eq p2.hash
        expect(p3.hash).not_to eq p4.hash
      end
    end

    describe '#<=>' do
      it 'sorts by name' do
        p1 = Package.new('bob')
        p2 = Package.new('jim')
        p3 = Package.new('dan')

        expect([p2, p1, p3].sort).to eq([p1, p3, p2])
      end
    end
  end
end
