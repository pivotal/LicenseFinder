require 'json'

module LicenseFinder
  class Rebar < PackageManager
    def initialize(options={})
      super
      @command = options[:rebar_command] || "rebar"
      @deps_path = options[:rebar_deps_dir] || "deps"
    end

    def current_packages
      rebarDeps = rebar_json
      JSON(rebarDeps).values.map do |dep|
        RebarPackage.new(
          dep["name"],
          dep["version"],
          File.join("#{@deps_path}", dep["name"]),
          dep
        )
      end
    end

    private

    def rebar_json

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
      JSON(dependencies)
    end

    def capture(command)
      [`#{command}`, $?.success?]
    end

    def package_path
      project_path.join('rebar.config')
    end

    def lockfile_path
      package_path.dirname.join('rebar.config.lock')
    end
  end
end