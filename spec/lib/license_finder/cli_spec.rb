require "spec_helper"

module LicenseFinder
  module CLI
    describe Dependencies do
      describe "add" do
        it "adds a dependency" do
          expect(DependencyManager).to receive(:manually_add).with("MIT", "js_dep", "1.2.3")

          silence_stdout do
            subject.add("MIT", "js_dep", "1.2.3")
          end
        end

        it "does not require a version" do
          expect(DependencyManager).to receive(:manually_add).with("MIT", "js_dep", nil)

          silence_stdout do
            subject.add("MIT", "js_dep")
          end
        end

        it "has an --approve option to approve the added dependency" do
          expect(DependencyManager).to receive(:manually_add).with("MIT", "js_dep", "1.2.3")
          expect(DependencyManager).to receive(:approve!).with("js_dep", "Julian", "We really need this")

          silence_stdout do
            Main.start(["dependencies", "add", "--approve", "--approver", "Julian", "--message", "We really need this", "MIT", "js_dep", "1.2.3"])
          end
        end
      end

      describe "remove" do
        it "removes a dependency" do
          expect(DependencyManager).to receive(:manually_remove).with("js_dep")
          silence_stdout do
            subject.remove("js_dep")
          end
        end
      end
    end

    describe Whitelist do
      let(:config) { LicenseFinder.config }

      describe "list" do
        it "shows the whitelist of licenses" do
          expect(config).to receive(:whitelist).and_return([])

          silence_stdout do
            subject.list
          end
        end
      end

      describe "add" do
        it "adds the specified license to the whitelist" do
          expect(config.whitelist).to receive(:push).with("test")
          expect(config).to receive(:save)
          expect(DependencyManager).to receive(:sync_with_package_managers)

          silence_stdout do
            subject.add("test")
          end
        end

        it "adds multiple licenses to the whitelist" do
          expect(config.whitelist).to receive(:push).with("test")
          expect(config.whitelist).to receive(:push).with("rest")
          expect(config).to receive(:save)
          expect(DependencyManager).to receive(:sync_with_package_managers)

          silence_stdout do
            subject.add("test", "rest")
          end
        end
      end

      describe "remove" do
        it "removes the specified license from the whitelist" do
          expect(config).to receive(:save)
          expect(config.whitelist).to receive(:delete).with("test")
          expect(DependencyManager).to receive(:sync_with_package_managers)

          silence_stdout do

            subject.remove("test")
          end
        end

        it "removes multiple licenses from the whitelist" do
          expect(config).to receive(:save)
          expect(config.whitelist).to receive(:delete).with("test")
          expect(config.whitelist).to receive(:delete).with("rest")
          expect(DependencyManager).to receive(:sync_with_package_managers)

          silence_stdout do
            subject.remove("test", "rest")
          end
        end
      end
    end

    describe ProjectName do
      let(:config) { LicenseFinder.config }

      describe "set" do
        it "sets the project name" do
          expect(config).to receive(:save)
          expect(config.project_name).not_to eq("new_project_name")
          expect(DependencyManager).to receive(:sync_with_package_managers)

          silence_stdout do
            subject.set("new_project_name")
          end

          expect(config.project_name).to eq("new_project_name")
        end
      end
    end

    describe IgnoredBundlerGroups do
      let(:config) { LicenseFinder.config }

      describe "list" do
        it "shows the ignored groups in the standard output" do
          expect(config).to receive(:ignore_groups).and_return(['development'])

          expect(capture_stdout { subject.list }).to match /development/
        end
      end

      describe "add" do
        it "adds the specified group to the ignored groups list" do
          expect(config.ignore_groups).to receive(:push).with("test")
          expect(config).to receive(:save)
          expect(DependencyManager).to receive(:sync_with_package_managers)

          silence_stdout do
            subject.add("test")
          end
        end
      end

      describe "remove" do
        it "removes the specified group from the ignored groups list" do
          expect(config.ignore_groups).to receive(:delete).with("test")
          expect(config).to receive(:save)
          expect(DependencyManager).to receive(:sync_with_package_managers)

          silence_stdout do
            subject.remove("test")
          end
        end
      end
    end

    describe IgnoredDependencies do
      let(:config) { LicenseFinder.config }

      describe "list" do
        context "when there is at least one ignored dependency" do
          it "shows the ignored dependencies" do
            expect(config).to receive(:ignore_dependencies).and_return(['bundler'])
            expect(capture_stdout { subject.list }).to match /bundler/
          end
        end

        context "when there are no ignored dependencies" do
          it "prints '(none)'" do
            expect(config).to receive(:ignore_dependencies).and_return([])
            expect(capture_stdout { subject.list }).to match /\(none\)/
          end
        end
      end

      describe "add" do
        it "adds the specified group to the ignored groups list" do
          expect(config.ignore_dependencies).to receive(:push).with("test")
          expect(config).to receive(:save)
          expect(DependencyManager).to receive(:sync_with_package_managers)

          silence_stdout do
            subject.add("test")
          end
        end
      end

      describe "remove" do
        it "removes the specified group from the ignored groups list" do
          expect(config.ignore_dependencies).to receive(:delete).with("test")
          expect(config).to receive(:save)
          expect(DependencyManager).to receive(:sync_with_package_managers)

          silence_stdout do
            subject.remove("test")
          end
        end
      end
    end

    describe Main do
      describe "default" do
        it "checks for action items" do
          expect(DependencyManager).to receive(:sync_with_package_managers)
          allow(Dependency).to receive(:unapproved) { [] }
          silence_stdout do
            described_class.start([])
          end
        end
      end

      describe "#rescan" do
        it "resyncs with Gemfile" do
          expect(DependencyManager).to receive(:sync_with_package_managers)
          allow(Dependency).to receive(:unapproved) { [] }

          silence_stdout do
            subject.rescan
          end
        end
      end

      describe "#license" do
        it "updates the license on the requested gem" do
          expect(DependencyManager).to receive(:license!).with("foo_gem", "foo")

          silence_stdout do
            subject.license 'foo', 'foo_gem'
          end
        end
      end

      describe "#approve" do
        it "approves the requested gem" do
          expect(DependencyManager).to receive(:approve!).with("foo", nil, nil)

          silence_stdout do
            subject.approve 'foo'
          end
        end

        it "approves multiple gem" do
          expect(DependencyManager).to receive(:approve!).with("foo", nil, nil)
          expect(DependencyManager).to receive(:approve!).with("bar", nil, nil)

          silence_stdout do
            subject.approve 'foo', 'bar'
          end
        end

        it "raises a warning if no gem was specified" do
          expect(DependencyManager).not_to receive(:approve!)

          silence_stdout do
            expect { subject.approve }.to raise_error(ArgumentError)
          end
        end

        it "sets approver and approval message" do
          expect(DependencyManager).to receive(:approve!).with("foo", "Julian", "We really need this")

          silence_stdout do
            Main.start(["approve", "--approver", "Julian", "--message", "We really need this", "foo"])
          end
        end
      end

      describe "#action_items" do
        it "reports unapproved dependencies" do
          allow(Dependency).to receive(:unapproved) { ['one dependency'] }
          allow(TextReport).to receive(:new) { double(:report, to_s: "a report!") }
          silence_stdout do
            allow(subject).to receive(:say)
            expect(subject).to receive(:say).with(/dependencies/i, :red)
            expect { subject.action_items }.to raise_error(SystemExit)
          end
        end

        it "reports that all dependencies are approved" do
          allow(Dependency).to receive(:unapproved) { [] }
          silence_stdout do
            expect(subject).to receive(:say).with(/approved/i, :green)
            expect { subject.action_items }.to_not raise_error
          end
        end
      end
    end
  end
end
