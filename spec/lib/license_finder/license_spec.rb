require 'spec_helper'

module LicenseFinder
  describe License do
    describe ".find_by_name" do
      it "should find a registered license" do
        expect(License.find_by_name("Apache2")).to be_a License
      end

      it "should make an unrecognized license" do
        license = License.find_by_name("not a known license")

        expect(license).to be_a License
        expect(license.name).to eq "not a known license"
      end

      context "making the default license" do
        it "set the name to 'unknown'" do
          expect(License.find_by_name(nil).name).to eq("unknown")
        end

        it "does not equal other uses of the default license" do
          expect(License.find_by_name(nil)).not_to eq(License.find_by_name(nil))
        end
      end
    end

    describe ".find_by_text" do
      it "should find a registered license" do
        expect(License.find_by_text('This gem is released under the MIT license')).to be_a License
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
        matcher: License::Matcher.from_text('Default Matcher')
      }

      License.new(defaults.merge(settings))
    end

    describe "#matches_name?" do
      it "should match on short_name" do
        expect(make_license(short_name: "Foo")).to be_matches_name "Foo"
      end

      it "should match on pretty name" do
        expect(make_license(pretty_name: "Foo")).to be_matches_name "Foo"
      end

      it "should match on alternative names" do
        license = make_license(other_names: ["Foo", "Bar"])
        expect(license).to be_matches_name "Foo"
        expect(license).to be_matches_name "Bar"
      end

      it "should ignore case" do
        expect(make_license(pretty_name: "Foo")).to be_matches_name "foo"
        expect(make_license(pretty_name: "foo")).to be_matches_name "Foo"
      end

      it "should not fail if pretty_name or other_names are omitted" do
        expect(make_license).to be_matches_name "Default Short Name"
      end
    end

    describe ".matches_text?" do
      it "should match on text" do
        license = make_license(matcher: License::Matcher.from_regex(/The license text/))
        expect(license).to be_matches_text "The license text"
        expect(license).not_to be_matches_text "Some other text"
      end

      it "should match regardless of placeholder names, whitespace, or quotes" do
        license_text = <<-LICENSE
          The "company" of <company name> shall not be
          held `responsible` for 'anything'.
        LICENSE
        license = make_license(matcher: License::Matcher.from_text(License::Text.normalize_punctuation(license_text)))

        expect(license).to be_matches_text <<-FILE
          The ''company'' of foo bar *%*%*%*%
          shall not be held "responsible" for `anything`.
        FILE
      end

      it "should match even if whitespace at beginning and end don't match" do
        template = License::Template.new("\nThe license text")
        license = make_license(matcher: License::Matcher.from_template(template))
        expect(license).to be_matches_text "The license text\n"
      end
    end

    it "should default pretty_name to short_name" do
      expect(make_license.name).to eq("Default Short Name")
    end
  end
end
