require 'spec_helper'

describe LicenseFinder::License::GPLv2 do
  subject { LicenseFinder::License::GPLv2.new("") }

  it_behaves_like "a license matcher"
end
