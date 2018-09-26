# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Conan do
    it_behaves_like 'a PackageManager'

    subject { Conan.new(project_path: Pathname('/fake/path'), logger: double(:logger, active: nil, log: true)) }
    describe '#current_packages' do
      let(:content) do
        '[requires]
Poco/1.7.8p3@pocoproject/stable

[generators]
cmake

[imports]
., license* -> ./licenses @ folder=True, ignore_case=True'
      end

      let(:conaninfo) do
        'PROJECT
    ID: 4c3dfe99a9c2d5003148e0054b9bacf58ac69f66
    BuildID: None
    Requires:
        Poco/1.7.9@pocoproject/stable
        OpenSSL/1.0.2l@conan/stable
        range-v3/0.3.0@ericniebler/stable
OpenSSL/1.0.2l@conan/stable
    ID: 0197c20e330042c026560da838f5b4c4bf094b8a
    BuildID: None
    Remote: conan-center=https://conan.bintray.com
    URL: http://github.com/lasote/conan-openssl
    License: The current OpenSSL licence is an \'Apache style\' license: https://www.openssl.org/source/license.html
    Updates: Version not checked
    Creation date: 2017-08-21 10:28:57
    Required by:
        Poco/1.7.9@pocoproject/stable
        PROJECT
    Requires:
        zlib/1.2.11@conan/stable
Poco/1.7.8p3@pocoproject/stable
    ID: 33fe7ea34efc04fb6d81fabd9e34f51da57f9e09
    BuildID: None
    Remote: conan-center=https://conan.bintray.com
    URL: http://github.com/lasote/conan-poco
    License: The Boost Software License 1.0
    Updates: Version not checked
    Creation date: 2017-09-20 16:51:10
    Required by:
        PROJECT
    Requires:
        OpenSSL/1.0.2l@conan/stable
zlib/1.2.11@conan/stable
    ID: 09512ff863f37e98ed748eadd9c6df3e4ea424a8
    BuildID: None
    Remote: conan-center=https://conan.bintray.com
    URL: http://github.com/lasote/conan-zlib
    License: http://www.zlib.net/zlib_license.html
    Updates: Version not checked
    Creation date: 2017-09-25 14:42:53
    Required by:
        OpenSSL/1.0.2l@conan/stable'
      end

      before do
        FakeFS.activate!
        FileUtils.mkdir_p '/fake/path'
        File.write('/fake/path/conanfile.txt', content)
      end

      after do
        FakeFS.deactivate!
      end

      it 'should return active' do
        expect(subject.active?).to be_truthy
      end

      describe '.current_packages' do
        context 'when license folder exists' do
          before do
            FileUtils.mkdir_p '/fake/path/licenses/zlib/license'
            FileUtils.mkdir_p '/fake/path/licenses/OpenSSL'
            FileUtils.mkdir_p '/fake/path/licenses/Poco/license'
            File.write('/fake/path/licenses/zlib/license/LICENSE', 'zlib license')
            File.write('/fake/path/licenses/OpenSSL/LICENSE', 'OpenSSL license')
            File.write('/fake/path/licenses/Poco/license/LICENSE', 'Poco license')
            expect(SharedHelpers::Cmd).to receive(:run).with('conan install .').ordered
            expect(SharedHelpers::Cmd).to receive(:run).with('conan info .').ordered.and_return([conaninfo, '', cmd_success])
          end

          it 'should list all the current packages name and version' do
            expect(subject.current_packages.map { |p| [p.name, p.version] }).to eq [
              ['OpenSSL', '1.0.2l'],
              ['Poco', '1.7.8p3'],
              ['zlib', '1.2.11']
            ]
          end

          it 'should obtain license text for each of the dependencies' do
            expect(ConanPackage).to receive(:new).with('OpenSSL', '1.0.2l', 'OpenSSL license', anything)
            expect(ConanPackage).to receive(:new).with('Poco', '1.7.8p3', 'Poco license', anything)
            expect(ConanPackage).to receive(:new).with('zlib', '1.2.11', 'zlib license', anything)
            subject.current_packages
          end

          it 'should obtain the url from conan info' do
            expect(ConanPackage).to receive(:new).with('OpenSSL', '1.0.2l', anything, 'http://github.com/lasote/conan-openssl')
            expect(ConanPackage).to receive(:new).with('Poco', '1.7.8p3', anything, 'http://github.com/lasote/conan-poco')
            expect(ConanPackage).to receive(:new).with('zlib', '1.2.11', anything, 'http://github.com/lasote/conan-zlib')
            subject.current_packages
          end
        end
      end
    end
  end
end
