require 'yajl'
require 'tempfile'

module LicenseFinder
  class NPM < PackageManager
    DEPENDENCY_GROUPS = ["dependencies", "devDependencies"]

    def current_packages
      top_level_deps = npm_json['dependencies']&.values || []
      package_json = JSON.parse(File.read(package_path), :max_nesting => false)
      top_level_deps.each do |dep|
        dep['groups'] = DEPENDENCY_GROUPS.select do |group|
          package_json[group]&.keys&.include? dep['name']
        end
      end
      dependency_matches = flatten(top_level_deps)
      dependency_matches = dependency_matches.group_by {|dep| [dep['name'], dep['version']]}
      dependency_matches.map {|id, dep_matches| construct_npm_package(dep_matches, id)}
    end

    private

    def self.package_management_command
      "npm"
    end

    def package_path
      project_path.join('package.json')
    end

    def npm_json
      tempfile = Tempfile.new
      begin
        command = "#{NPM::package_management_command} list --json --long > #{tempfile.path}"
        output, success = Dir.chdir(project_path) { capture(command) }

        if success
          json = Yajl::Parser.parse(File.open(tempfile.path))
        else
          json = begin
            Yajl::Parser.parse(File.open(tempfile.path))
          rescue Yajl::ParseError
            nil
          end
          if json
            $stderr.puts "Command '#{command}' returned an error but parsing succeeded."
          else
            raise "Command '#{command}' failed to execute: #{output}"
          end
        end
      ensure
        tempfile.close
        tempfile.unlink
      end
      json
    end

    def flatten(list)
      list.inject [] {|acc, dep| acc + [dep] + flatten(dep['dependencies']&.values&.map {|inner_dep| inner_dep['groups'] = dep['groups']; inner_dep} || [])}
    end

    def licenses(dep_matches)
      licenses_lists = dep_matches.map do |match|
        match['licenses']
      end

      licenses_lists.reject! {|licenses| licenses.nil? || licenses == '[Circular]'}
      licenses_lists = licenses_lists.uniq
      case licenses_lists.count
        when 0
          dep_matches.map {|dep_match| dep_match['license']}.reject(&:nil?).uniq
        when 1
          licenses_lists.first.map {|license| license['type']}
        else
          raise "Varying lists of licenses provided for #{dep_matches.first['name']} (#{dep_matches.first['version']})"
      end
    end

    def construct_npm_package(dep_matches, id)
      name, version = id
      homepage = dep_matches.map {|match| match['homepage']}.reject(&:nil?).uniq&.first
      description = dep_matches.map {|match| match['description']}.reject(&:nil?).uniq&.first
      package = NpmPackage.new({'name' => name,
                                'version' => version,
                                'homepage' => homepage,
                                'description' => description,
                                'licenses' => licenses(dep_matches)},
                               logger: logger)
      dep_matches.map {|match| match['groups']}.flatten.uniq.each {|group|
        package.groups << group
      }
      package
    end
  end
end
