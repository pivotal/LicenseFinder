# frozen_string_literal: true

require 'spec_helper'
require 'license_finder/shared_helpers/common_path'

describe CommonPathHelper do
  context 'when the GVT returns entries with same sha with common base path' do
    let(:gvt_output_with_common_paths) do
      %w[cloud.google.com/go/bigquery cloud.google.com/go/civil cloud.google.com/go/compute/metadata]
    end
    let(:gvt_output_without_common_paths) do
      %w[cloud.google.com/go/bigquery/adsf cloud.google.com/go/civil cloud.aws.com/go/metadata]
    end
    let(:gvt_output_with_github_common_path) do
      %w[github.com/cloud.google.com/go/bigquery github.com/stuff/cloud.google.com/go/civil github.com/things/cloud.google.com/go/compute/metadata]
    end

    it 'only shows the entry with common base path once' do
      paths = CommonPathHelper.longest_common_paths gvt_output_with_common_paths
      expect(paths).to match_array %w[cloud.google.com/go]
    end

    it 'shows entries with same sha when they do not have a common base path' do
      paths = CommonPathHelper.longest_common_paths gvt_output_without_common_paths
      expect(paths).to match_array %w[cloud.google.com/go cloud.aws.com/go/metadata]
    end

    it 'shows all paths when the longest path is a single directory' do
      paths = CommonPathHelper.longest_common_paths gvt_output_with_github_common_path
      expect(paths).to match_array gvt_output_with_github_common_path
    end
  end
end
