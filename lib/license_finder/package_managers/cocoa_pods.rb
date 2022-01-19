# frozen_string_literal: true

require 'json'

module LicenseFinder
  class CocoaPods < PackageManager
    def current_packages
      podfile = YAML.load_file(lockfile_path)

      podfile['PODS'].map do |pod|
        pod = pod.keys.first if pod.is_a?(Hash)

        name, version = pod.scan(/(.*)\s\((.*)\)/).flatten

        CocoaPodsPackage.new(
          name,
          version,
          license_texts[name],
          logger: logger
        )
      end
    end

    def package_management_command
      LicenseFinder::Platform.darwin? ? 'pod' : nil
    end

    def possible_package_paths
      [project_path.join('Podfile')]
    end

    private

    def lockfile_path
      project_path.join('Podfile.lock')
    end

    def license_texts
      # package name => license text
      @license_texts ||= read_plist(acknowledgements_path)['PreferenceSpecifiers']
                         .each_with_object({}) { |hash, memo| memo[hash['Title']] = hash['FooterText'] }
    end

    def acknowledgements_path

      if !ENV['ACKNOWLEDGEMENTS_PATH'].nil?
        result = Dir[*ENV['ACKNOWLEDGEMENTS_PATH']].first
      else
        search_paths = ['Pods/Pods-acknowledgements.plist',
                        'Pods/Target Support Files/Pods/Pods-acknowledgements.plist',
                        'Pods/Target Support Files/Pods-*/Pods-*-acknowledgements.plist']

        result = Dir[*search_paths.map { |path| File.join(project_path, path) }].first
        raise "Found a Podfile but no Pods directory in #{project_path}. Try running pod install before running license_finder." if result.nil?
      end
      result
    end

    def read_plist(pathname)
      transformed_pathname = pathname.gsub!(%r{[^0-9A-Za-z. \-'/]}, '')
      transformed_pathname = pathname if transformed_pathname.nil?
      JSON.parse(`plutil -convert json -o - '#{transformed_pathname}'`)
    end
  end
end
