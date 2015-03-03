require "json"

module LicenseFinder
  class CocoaPods < PackageManager
    def current_packages
      podfile = YAML.load_file(lockfile_path)

      acknowledgements = read_plist(acknowledgements_path)["PreferenceSpecifiers"]

      podfile["PODS"].map do |pod|
        pod = pod.keys.first if pod.is_a?(Hash)

        name, version = pod.scan(/(.*)\s\((.*)\)/).flatten
        acknowledgment = acknowledgements.detect { |hash| hash["Title"] == name } || {}

        CocoaPodsPackage.new(
          name,
          version,
          acknowledgment["FooterText"],
          logger: logger
        )
      end
    end

    private

    def package_path
      project_path.join("Podfile")
    end

    def lockfile_path
      project_path.join("Podfile.lock")
    end

    def acknowledgements_path
      filename = 'Pods-acknowledgements.plist'
      directories = [
        'Pods',                          # cocoapods < 0.34
        'Pods/Target Support Files/Pods' # cocoapods >= 0.34
      ]

      directories.map { |dir| project_path.join(dir, filename) }.find(&:exist?)
    end

    def read_plist pathname
      JSON.parse(`plutil -convert json -o - '#{pathname.expand_path}'`)
    end
  end
end
