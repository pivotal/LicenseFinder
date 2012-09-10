require 'spec_helper'

describe LicenseFinder::License::ISC do
  subject { LicenseFinder::License::ISC.new("") }

  it_behaves_like "a license matcher"
end
