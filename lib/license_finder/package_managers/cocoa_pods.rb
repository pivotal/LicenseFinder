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

    def self.package_management_command
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
      search_paths = ['Pods/Pods-acknowledgements.plist',
                      'Pods/Target Support Files/Pods/Pods-acknowledgements.plist',
                      'Pods/Target Support Files/Pods-*/Pods-*-acknowledgements.plist']

      Dir[*search_paths.map { |path| File.join(project_path, path) }].first
    end

    def read_plist(pathname)
      JSON.parse(`plutil -convert json -o - '#{pathname}'`)
    end
  end
end
