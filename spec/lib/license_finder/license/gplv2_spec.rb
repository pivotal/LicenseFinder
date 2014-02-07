require 'spec_helper'

describe LicenseFinder::License, "GPLv2" do
  it "should be findable" do
    described_class.find_by_name("GPLv2").should be
  end
end
