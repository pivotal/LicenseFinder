require 'spec_helper'

describe LicenseFinder::License, "Apache2" do
  let(:license) { LicenseFinder::License.find_by_name("Apache2") }

  specify { described_class.find_by_name("Apache2").should be license }
  specify { described_class.find_by_name("Apache 2.0").should be license }
  specify { described_class.find_by_name("Apache-2.0").should be license }
end
