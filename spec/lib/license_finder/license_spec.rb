require 'spec_helper'

module LicenseFinder
  describe License do
    describe ".find_by_name" do
      it "should find a registered license" do
        License.find_by_name("Apache2").should be_a License
      end

      it "should make an unrecognized license" do
        license = License.find_by_name("not a known license")

        expect(license).to be_a License
        expect(license.name).to eq "not a known license"
      end

      context "making the default license" do
        it "set the name to 'other'" do
          License.find_by_name(nil).name.should == "other"
        end

        it "does not equal other uses of the default license" do
          License.find_by_name(nil).should_not == License.find_by_name(nil)
        end

        context "when there is a whitelist" do
          before do
            LicenseFinder.config.stub(:whitelist).and_return(["not empty"])
          end

          it "does not blow up" do
            License.find_by_name(nil).name.should == "other"
          end
        end
      end
    end

    describe ".find_by_text" do
      it "should find a registered license" do
        License.find_by_text('This gem is released under the MIT license').should be_a License
      end

      it "returns nil if not found" do
        license = License.find_by_text("foo")

        expect(license).to be_nil
      end
    end

    def make_license(settings = {})
      defaults = {
        short_name: "Default Short Name",
        url: "http://example.com/license",
        whitelisted: false,
        matcher: License::Matcher.from_text('Default Matcher')
      }

      License.new(defaults.merge(settings))
    end

    describe "#whitelisted?" do
      it "is true if the settings say it is" do
        make_license.should_not be_whitelisted
        make_license(whitelisted: true).should be_whitelisted
      end

      it "can be made true (without mutating original)" do
        original = make_license
        license = original.whitelist
        license.should_not == original
        license.should be_whitelisted
        license.url.should == "http://example.com/license"
        license.should be_matches_name "Default Short Name"
        license.should be_matches_text "Default Matcher"
      end
    end

    describe "#matches_name?" do
      it "should match on short_name" do
        make_license(short_name: "Foo").should be_matches_name "Foo"
      end

      it "should match on pretty name" do
        make_license(pretty_name: "Foo").should be_matches_name "Foo"
      end

      it "should match on alternative names" do
        license = make_license(other_names: ["Foo", "Bar"])
        license.should be_matches_name "Foo"
        license.should be_matches_name "Bar"
      end

      it "should ignore case" do
        make_license(pretty_name: "Foo").should be_matches_name "foo"
        make_license(pretty_name: "foo").should be_matches_name "Foo"
      end

      it "should not fail if pretty_name or other_names are omitted" do
        make_license.should be_matches_name "Default Short Name"
      end
    end

    describe ".matches_text?" do
      it "should match on text" do
        license = make_license(matcher: License::Matcher.from_regex(/The license text/))
        license.should be_matches_text "The license text"
        license.should_not be_matches_text "Some other text"
      end

      it "should match regardless of placeholder names, whitespace, or quotes" do
        license_text = <<-LICENSE
          The "company" of <company name> shall not be
          held `responsible` for 'anything'.
        LICENSE
        license = make_license(matcher: License::Matcher.from_text(License::Text.normalize_punctuation(license_text)))

        license.should be_matches_text <<-FILE
          The ''company'' of foo bar *%*%*%*%
          shall not be held "responsible" for `anything`.
        FILE
      end

      it "should match even if whitespace at beginning and end don't match" do
        template = License::Template.new("\nThe license text")
        license = make_license(matcher: License::Matcher.from_template(template))
        license.should be_matches_text "The license text\n"
      end
    end

    it "should default pretty_name to short_name" do
      make_license.name.should == "Default Short Name"
    end
  end
end
