module LicenseFinder
  class Rebar < PackageManager
    def initialize(options={})
      super
      @command = options[:rebar_command] || "rebar"
      @deps_path = Pathname(options[:rebar_deps_dir] || "deps")
    end

    def current_packages
      rebarDeps = rebar_deps
      rebarDeps.values.map do |dep|
        RebarPackage.new(
          dep["name"],
          dep["version"],
          @deps_path.join(dep["name"]),
          dep
        )
      end
    end

    private

    def rebar_deps

      command = "#{@command} list-deps"
      output, success = capture(command)
      dependencies = {}
      if success
        lines = output.split("\n")
        lines.each do |i|
          if !i.start_with?("=")
            dependency = i.split(" ")
            dependencies[dependency[0]] = {
              "name" => dependency[0],
              "version" => "#{dependency[1]}: #{dependency[2]}",
              "homepage" => dependency[3]
            }
          end
        end
      else
        raise "Command #{command} failed to execute: #{output}"
      end
      dependencies
    end

    def capture(command)
      [`#{command}`, $?.success?]
    end

    def package_path
      project_path.join('rebar.config')
    end
  end
end