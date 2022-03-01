# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Pub do
    let(:root) { '/fake-pub-project' }
    let(:project_path) { fixture_path('all_pms') }
    let(:pub) { Pub.new(project_path: project_path) }
    let(:new_bsd_common_text) do
      "Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of <organization> nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
    end

    it_behaves_like 'a PackageManager'

    def stub_resolved(frameworks)
      allow(IO).to receive(:read)
                    .with(project_path.join('pubspec.lock'))
                    .and_return(frameworks)
    end

    def stub_license_md(hash = {})
      hash.each_key do |key|
        license_pattern = project_path.join('.pub/hosted/pub.dartlang.org/', key, 'LICENSE*')
        filename = project_path.join('.pub/hosted/pub.dartlang.org/', key, 'LICENSE')
        allow(IO).to receive(:read)
                      .with(filename)
                      .and_return(hash[key])

        allow(File).to receive(:exist?)
                        .with(filename)
                        .and_return(true)

        allow(Dir).to receive(:glob)
                        .with(license_pattern, File::FNM_CASEFOLD)
                        .and_return([filename])
      end
    end

    let(:dependency_json) do
      FakeFS.without do
        fixture_from('pub_deps.json')
      end
    end

    before do
      allow(IO).to receive(:read).and_call_original
      allow(File).to receive(:exist?).and_return(false)
      allow(Dir).to receive(:glob).and_return([])
    end
    describe 'current_packages' do
      context 'when PUB already ran and pubspec.lock exists' do
        before do
          allow(File).to receive(:exist?).and_return(true)
          allow(SharedHelpers::Cmd).to receive(:run).with('flutter pub deps --json')
                                                    .and_return([dependency_json, '', cmd_success])
          allow(ENV).to receive(:[]).with('PUB_CACHE').and_return(project_path.join('.pub'))
        end

        it 'lists all the current packages' do
          expect(pub.current_packages.map { |p| [p.name, p.version] }).to eq [
            ['flutter', '0.0.0'],
            ['device_info', '2.0.3']
          ]
        end

        it 'passes the license text to the package' do
          stub_license_md('device_info-2.0.3' => new_bsd_common_text)
          expect(pub.current_packages.last.licenses.map(&:name)).to eq ['New BSD']
        end

        it 'handles no licenses' do
          expect(pub.current_packages.first.licenses.map(&:name)).to eq ['unknown']
        end
      end
    end
  end
end
