# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe ConanInfoParser do
    subject { ConanInfoParser.new }
    let(:parsed_config) do
      [
        {
          'name' => 'PROJECT',
          'ID' => '4c3dfe99a9c2d5003148e0054b9bacf58ac69f66',
          'BuildID' => 'None',
          'Requires' => ['Poco/1.7.9@pocoproject/stable', 'OpenSSL/1.0.2l@conan/stable', 'range-v3/0.3.0@ericniebler/stable']
        },
        {
          'name' => 'OpenSSL/1.0.2l@conan/stable',
          'ID' => '0197c20e330042c026560da838f5b4c4bf094b8a',
          'BuildID' => 'None',
          'Remote' => 'conan-center=https://conan.bintray.com',
          'URL' => 'http://github.com/lasote/conan-openssl',
          'License' => 'The current OpenSSL licence is an \'Apache style\' license: https://www.openssl.org/source/license.html',
          'Updates' => 'Version not checked',
          'Creation date' => '2017-08-21 10:28:57',
          'Required by' => ['Poco/1.7.9@pocoproject/stable', 'PROJECT'],
          'Requires' => ['zlib/1.2.11@conan/stable']
        },
        {
          'name' => 'Poco/1.7.9@pocoproject/stable',
          'ID' => '33fe7ea34efc04fb6d81fabd9e34f51da57f9e09',
          'BuildID' => 'None',
          'Remote' => 'conan-center=https://conan.bintray.com',
          'URL' => 'http://github.com/lasote/conan-poco',
          'License' => 'The Boost Software License 1.0',
          'Updates' => 'Version not checked',
          'Creation date' => '2017-09-20 16:51:10',
          'Required by' => ['PROJECT'],
          'Requires' => ['OpenSSL/1.0.2l@conan/stable']
        },
        {
          'name' => 'range-v3/0.3.0@ericniebler/stable',
          'ID' => '5ab84d6acfe1f23c4fae0ab88f26e3a396351ac9',
          'BuildID' => 'None',
          'Remote' => 'conan-center=https://conan.bintray.com',
          'URL' => 'https://github.com/ericniebler/range-v3',
          'License' => 'Boost Software License - Version 1.0 - August 17th, 2003',
          'Updates' => 'Version not checked',
          'Creation date' => '2017-06-30 13:20:56',
          'Required by' => ['PROJECT']
        },
        {
          'name' => 'zlib/1.2.11@conan/stable',
          'ID' => '09512ff863f37e98ed748eadd9c6df3e4ea424a8',
          'BuildID' => 'None',
          'Remote' => 'conan-center=https://conan.bintray.com',
          'URL' => 'http://github.com/lasote/conan-zlib',
          'License' => 'http://www.zlib.net/zlib_license.html',
          'Updates' => 'Version not checked',
          'Creation date' => '2017-09-25 14:42:53',
          'Required by' => ['OpenSSL/1.0.2l@conan/stable']
        }
      ]
    end
    it 'should parse valid conan info output' do
      expect(subject.parse(fixture_from('conan.txt'))).to eq(parsed_config)
    end
  end
end
