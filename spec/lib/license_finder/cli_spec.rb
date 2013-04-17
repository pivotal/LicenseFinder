require "spec_helper"

module LicenseFinder
  describe CLI do
    def silence_stdout
      orig_stdout = $stdout
      $stdout = File.open("/dev/null", "w")
      yield
    ensure
      $stdout = orig_stdout
    end

    describe "default" do
      it "should check for action items" do
        BundleSyncer.should_receive(:sync!)
        Dependency.stub(:unapproved) { [] }
        silence_stdout do
          described_class.start([])
        end
      end
    end

    describe "#rescan" do
      it "resyncs with Gemfile" do
        BundleSyncer.should_receive(:sync!)
        Dependency.stub(:unapproved) { [] }
        silence_stdout do
          subject.rescan
        end
      end
    end

    describe "#license" do
      it "should update the license on the requested gem" do
        dependency = double :dependency, :name => nil
        dependency.should_receive(:set_license_manually).with("foo")

        Dependency.stub(:first).with(name: "foo_gem").and_return(dependency)

        silence_stdout do
          subject.license 'foo', 'foo_gem'
        end
      end
    end

    describe "#approve" do
      it "should approve the requested gem" do
        dependency = double('dependency', :name => nil)
        dependency.should_receive(:approve!)

        Dependency.stub(:first).with(name: 'foo').and_return(dependency)

        silence_stdout do
          subject.approve 'foo'
        end
      end
    end

    describe "#action_items" do
      it "reports unapproved dependencies" do
        Dependency.stub(:unapproved) { ['one dependency'] }
        TextReport.stub(:new) { stub(:report, to_s: "a report!") }
        silence_stdout do
          $stdout.stub(:puts)
          $stdout.should_receive(:puts).with(/dependencies/i)
          expect { subject.action_items }.to raise_error(SystemExit)
        end
      end

      it "reports that all dependencies are approved" do
        Dependency.stub(:unapproved) { [] }
        silence_stdout do
          $stdout.should_receive(:puts).with(/approved/i)
          expect { subject.action_items }.to_not raise_error
        end
      end
    end
  end
end
