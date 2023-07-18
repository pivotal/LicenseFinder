# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe ConanInfoParser do
    subject { ConanInfoParser.new }
    let(:parsed_config) do
      [
        {
          'name' => 'conanfile.txt',
          'id' => '4c3dfe99a9c2d5003148e0054b9bacf58ac69f66',
          'buildid' => 'None',
          'requires' => ['Poco/1.7.9@pocoproject/stable', 'OpenSSL/1.0.2l@conan/stable', 'range-v3/0.3.0@ericniebler/stable']
        },
        {
          'name' => 'OpenSSL/1.0.2l@conan/stable',
          'id' => '0197c20e330042c026560da838f5b4c4bf094b8a',
          'buildid' => 'None',
          'remote' => 'conan-center=https://center.conan.io',
          'url' => 'http://github.com/lasote/conan-openssl',
          'license' => 'The current OpenSSL licence is an \'Apache style\' license: https://www.openssl.org/source/license.html',
          'updates' => 'Version not checked',
          'creation date' => '2017-08-21 10:28:57',
          'required by' => ['Poco/1.7.9@pocoproject/stable', 'conanfile.txt'],
          'requires' => ['zlib/1.2.11@conan/stable']
        },
        {
          'name' => 'Poco/1.7.9@pocoproject/stable',
          'id' => '33fe7ea34efc04fb6d81fabd9e34f51da57f9e09',
          'buildid' => 'None',
          'remote' => 'conan-center=https://center.conan.io',
          'url' => 'http://github.com/lasote/conan-poco',
          'license' => 'The Boost Software License 1.0',
          'updates' => 'Version not checked',
          'creation date' => '2017-09-20 16:51:10',
          'required by' => ['conanfile.txt'],
          'requires' => ['OpenSSL/1.0.2l@conan/stable']
        },
        {
          'name' => 'range-v3/0.3.0@ericniebler/stable',
          'id' => '5ab84d6acfe1f23c4fae0ab88f26e3a396351ac9',
          'buildid' => 'None',
          'remote' => 'conan-center=https://center.conan.io',
          'url' => 'https://github.com/ericniebler/range-v3',
          'license' => 'Boost Software License - Version 1.0 - August 17th, 2003',
          'updates' => 'Version not checked',
          'creation date' => '2017-06-30 13:20:56',
          'required by' => ['conanfile.txt']
        },
        {
          'name' => 'zlib/1.2.11@conan/stable',
          'id' => '09512ff863f37e98ed748eadd9c6df3e4ea424a8',
          'buildid' => 'None',
          'remote' => 'conan-center=https://center.conan.io',
          'url' => 'http://github.com/lasote/conan-zlib',
          'license' => 'http://www.zlib.net/zlib_license.html',
          'updates' => 'Version not checked',
          'creation date' => '2017-09-25 14:42:53',
          'required by' => ['OpenSSL/1.0.2l@conan/stable']
        }
      ]
    end
    it 'should parse valid conan info output' do
      expect(subject.parse(fixture_from('conan.txt'))).to eq(parsed_config)
    end
  end
end
