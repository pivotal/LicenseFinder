require 'spec_helper'

describe LicenseFinder::License::Apache2 do
  subject { LicenseFinder::License::Apache2.new("") }

  it_behaves_like "a license matcher"
end
