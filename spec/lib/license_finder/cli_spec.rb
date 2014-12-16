require "spec_helper"

module LicenseFinder
  module CLI
    context do
      let!(:dependency_manager) { DependencyManager.new(decisions: decisions) }
      let!(:decisions) { Decisions.new }

      before do
        allow(Decisions).to receive(:saved!) { decisions }
        allow(DependencyManager).to receive(:new) { dependency_manager }
      end

      describe Dependencies do
        describe "add" do
          it "adds a dependency" do
            silence_stdout do
              subject.add("MIT", "js_dep", "1.2.3")
            end

            expect(subject.decisions.packages.size).to eq 1
            package = subject.decisions.packages.first
            expect(package.name).to eq "js_dep"
            expect(package.version).to eq "1.2.3"
            expect(subject.decisions.license_of("js_dep")).to eq License.find_by_name("MIT")
          end

          it "does not require a version" do
            silence_stdout do
              subject.add("MIT", "js_dep")
            end
            package = subject.decisions.packages.first
            expect(package.version).to be_nil
          end

          it "has an --approve option to approve the added dependency" do
            expect(decisions).to receive(:approve).with("js_dep", hash_including(who: "Julian", why:  "We really need this"))
            silence_stdout do
              Main.start(["dependencies", "add", "--approve", "--approver", "Julian", "--message", "We really need this", "MIT", "js_dep", "1.2.3"])
            end
          end
        end

        describe "remove" do
          it "removes a dependency" do
            silence_stdout do
              subject.add("MIT", "js_dep")
              subject.remove("js_dep")
            end
            expect(subject.decisions.packages).to be_empty
          end
        end

        describe "list" do
          it "lists manually added dependencies" do
            allow(Decisions).to receive(:saved!) do
              Decisions.new.add_package("custom", nil)
            end
            expect(capture_stdout { subject.list }).to match /custom/
          end
        end
      end

      describe Whitelist do
        describe "list" do
          it "shows the whitelist of licenses" do
            allow(Decisions).to receive(:saved!) do
              Decisions.new.whitelist("MIT")
            end

            expect(capture_stdout { subject.list }).to match /MIT/
          end
        end

        describe "add" do
          it "adds the specified license to the whitelist" do
            silence_stdout do
              subject.add("test")
            end
            expect(subject.decisions.whitelisted).to eq [License.find_by_name("test")].to_set
          end

          it "adds multiple licenses to the whitelist" do
            silence_stdout do
              subject.add("test", "rest")
            end
            expect(subject.decisions.whitelisted).to eq [
              License.find_by_name("test"),
              License.find_by_name("rest")
            ].to_set
          end
        end

        describe "remove" do
          it "removes the specified license from the whitelist" do
            silence_stdout do
              subject.add("test")
              subject.remove("test")
            end
            expect(subject.decisions.whitelisted).to be_empty
          end

          it "removes multiple licenses from the whitelist" do
            silence_stdout do
              subject.add("test", "rest")
              subject.remove("test", "rest")
            end
            expect(subject.decisions.whitelisted).to be_empty
          end
        end
      end

      describe ProjectName do
        let(:config) { LicenseFinder.config }

        describe "set" do
          it "sets the project name" do
            expect(config).to receive(:save)
            expect(config.project_name).not_to eq("new_project_name")

            silence_stdout do
              subject.set("new_project_name")
            end

            expect(config.project_name).to eq("new_project_name")
          end
        end
      end

      describe IgnoredBundlerGroups do
        describe "list" do
          it "shows the ignored groups in the standard output" do
            allow(Decisions).to receive(:saved!) do
              Decisions.new.ignore_group("development")
            end

            expect(capture_stdout { subject.list }).to match /development/
          end
        end

        describe "add" do
          it "adds the specified group to the ignored groups list" do
            silence_stdout do
              subject.add("test")
            end
            expect(subject.decisions.ignored_groups).to eq ["test"].to_set
          end
        end

        describe "remove" do
          it "removes the specified group from the ignored groups list" do
            silence_stdout do
              subject.add("test")
              subject.remove("test")
            end
            expect(subject.decisions.ignored_groups).to be_empty
          end
        end
      end

      describe IgnoredDependencies do
        describe "list" do
          context "when there is at least one ignored dependency" do
            it "shows the ignored dependencies" do
              allow(Decisions).to receive(:saved!) do
                Decisions.new.ignore("bundler")
              end
              expect(capture_stdout { subject.list }).to match /bundler/
            end
          end

          context "when there are no ignored dependencies" do
            it "prints '(none)'" do
              expect(capture_stdout { subject.list }).to match /\(none\)/
            end
          end
        end

        describe "add" do
          it "adds the specified group to the ignored groups list" do
            silence_stdout do
              subject.add("test")
            end
            expect(subject.decisions.ignored).to eq ["test"].to_set
          end
        end

        describe "remove" do
          it "removes the specified group from the ignored groups list" do
            silence_stdout do
              subject.add("test")
              subject.remove("test")
            end
            expect(subject.decisions.ignored).to be_empty
          end
        end
      end

      describe Main do
        describe "default" do
          it "checks for action items" do
            allow(Decisions).to receive(:saved!) do
              Decisions.new.add_package("a dependency", nil)
            end

            silence_stdout do
              expect { described_class.start([]) }.to raise_error(SystemExit)
            end
          end
        end

        describe "#license" do
          it "updates the license on the requested gem" do
            silence_stdout do
              subject.license 'foo', 'foo_gem'
            end
            expect(subject.decisions.license_of("foo_gem").name).to eq "foo"
          end
        end

        describe "#approve" do
          it "approves the requested gem" do
            silence_stdout do
              subject.approve 'foo'
            end
            expect(subject.decisions).to be_approved "foo"
          end

          it "approves multiple gem" do
            silence_stdout do
              subject.approve 'foo', 'bar'
            end
            expect(subject.decisions).to be_approved "foo"
            expect(subject.decisions).to be_approved "bar"
          end

          it "raises a warning if no gem was specified" do
            silence_stdout do
              expect { subject.approve }.to raise_error(ArgumentError)
            end
          end

          it "sets approver and approval message" do
            expect(decisions).to receive(:approve).with("foo", hash_including(who: "Julian", why:  "We really need this"))

            silence_stdout do
              Main.start(["approve", "--approver", "Julian", "--message", "We really need this", "foo"])
            end
          end
        end

        describe "#report" do
          before do
            allow(dependency_manager).to receive(:current_packages) { [ManualPackage.new('one dependency')] }
          end

          it "reports acknowleged dependencies" do
            result = capture_stdout do
              Main.start(["report"])
            end
            expect(result).to eq "\"one dependency\", , other\n"
          end

          it "will output a specific format" do
            result = capture_stdout do
              Main.start(["report", "--format", "detailed_text"])
            end

            expect(result).to eq "one dependency,,other,\"\",\"\"\n"
          end
        end

        describe "#action_items" do
          it "reports unapproved dependencies" do
            allow(dependency_manager).to receive(:current_packages) { [ManualPackage.new('one dependency')] }
            allow(TextReport).to receive(:new) { double(:report, to_s: "a report!") }
            silence_stdout do
              allow(subject).to receive(:say)
              expect(subject).to receive(:say).with(/dependencies/i, :red)
              expect { subject.action_items }.to raise_error(SystemExit)
            end
          end

          it "reports that all dependencies are approved" do
            allow(dependency_manager).to receive(:current_packages) { [] }
            silence_stdout do
              expect(subject).to receive(:say).with(/approved/i, :green)
              expect { subject.action_items }.to_not raise_error
            end
          end
        end
      end
    end
  end
end
