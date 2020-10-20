#!/usr/bin/env ruby

# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'

# This is an example of how to programatically extract the information that
# LicenseFinder has about packages and their licenses.
# > bundle install
# > ./extract_license_data.rb

require 'license_finder'

# See lib/license_finder/core.rb for more configuration options.
# A quiet logger is required when running reports...
lf = LicenseFinder::Core.new(LicenseFinder::Configuration.with_optional_saved_config(logger: :quiet))

# Groups of packages
lf.acknowledged # All (non-ignored) packages license_finder is tracking
lf.unapproved # The packages which have not been approved or permitted
lf.restricted # The packages which have been restricted

# Package details
lf.acknowledged.each do |package|
  # Approvals
  package.approved? # Whether the package has been approved manually or permitted
  package.approved_manually?
  package.permitted?
  package.restricted?

  # Licensing
  # The set of licenses, each of which has a name and url, which
  # license_finder will report for this package.
  package.licenses
  # Additional information about how these licenses were chosen
  # (from decision, from spec, from files, or none-found).  See
  # LicenseFinder::Licensing and LicenseFinder::Activation
  package.activations
  # The files that look like licenses, found in the package's
  # directory.  Caveat: if a package's licenses were specified by a decision or
  # by the package's spec, the license_files will be ignored.  That means,
  # package.licenses may report different licenses than those found in
  # license_files.
  package.license_files
  package.license_files.each do |file|
    # The license found in this file.
    file.license
    # The text of the file.  Sometimes this will be an entire README file,
    # because license_finder has found the phrase "is released under the
    # MIT license" in it.
    file.text
  end
  package.licensing.activations_from_decisions # If license_finder only knew about decisions, what licenses would it report?
  package.licensing.activations_from_spec      # If license_finder only knew about package specs, what licenses would it report?
  package.licensing.activations_from_files     # If license_finder only knew about package files, what licenses would it report?
  package.licensing.activations_from_files.each do |activation|
    # Each activation groups together all files that point to the same license.
    # Each file contains its #license and #text.
    activation.license
    activation.files
  end
end
