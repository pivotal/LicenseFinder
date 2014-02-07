require 'spec_helper'

describe LicenseFinder::License, "Apache2" do
  it "should be findable" do
    described_class.find_by_name("Apache2").should be
  end
end
