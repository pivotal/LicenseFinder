require 'spec_helper'

describe LicenseFinder::License::LGPL do
  subject { LicenseFinder::License::LGPL.new("") }

  it_behaves_like "a license matcher"
end
