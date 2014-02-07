require 'spec_helper'

describe LicenseFinder::License, "LGPL" do
  it "should be findable" do
    described_class.find_by_name("LGPL").should be
  end
end
