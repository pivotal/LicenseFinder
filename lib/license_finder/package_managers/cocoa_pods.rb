require "json"

module LicenseFinder
  class CocoaPods

    def self.current_packages
      podfile = YAML.load_file(lockfile_path)

      acknowledgements = JSON.parse(`plutil -convert json -o - #{Pathname.new('Pods/Pods-acknowledgements.plist').expand_path}`)["PreferenceSpecifiers"]

      podfile["PODS"].map do |pod|
        pod = pod.keys.first if pod.is_a?(Hash)

        pod_name, pod_version = pod.scan(/(.*)\s\((.*)\)/).flatten
        pod_acknowledgment = acknowledgements.detect { |hash| hash["Title"] == pod_name } || {}
        CocoaPodsPackage.new(pod_name, pod_version, pod_acknowledgment["FooterText"])
      end
    end

    def self.active?
      package_path.exist?
    end

    private

    def self.package_path
      Pathname.new("Podfile")
    end

    def self.lockfile_path
      Pathname.new("Podfile.lock")
    end

  end
end
