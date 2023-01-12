# frozen_string_literal: true

module LicenseFinder
  class MavenDependencyFinder
    def initialize(project_path, m2_path)
      @project_path = project_path
      @m2_path = m2_path
    end

    def dependencies
      options = {
        'GroupTags' => { 'licenses' => 'license', 'dependencies' => 'dependency' },
        'ForceArray' => %w[license dependency]
      }

      Pathname
        .glob(@project_path.join('**', 'target', 'generated-resources', 'licenses.xml'))
        .map(&:read)
        .flat_map { |xml| XmlSimple.xml_in(xml, options)['dependencies'] }
        .reject(&:empty?)
        .each { |dep| add_info_from_m2(dep) }
    end

    # Add the name of the JAR file to allow later retrieval of license and notice files,
    # and add the name, description and URL from the POM XML file.
    def add_info_from_m2(dep)
      m2_artifact_dir = @m2_path
        .join(dep['groupId'].tr('.', '/'))
        .join(dep['artifactId'])
        .join(dep['version'])
      artifact_basename = "#{dep['artifactId']}-#{dep['version']}"

      dep.store('jarFile', m2_artifact_dir.join("#{artifact_basename}.jar"))

      add_info_from_pom(m2_artifact_dir.join("#{artifact_basename}.pom"), dep)
    end

    # Extract name, description and URL from pom.xml
    def add_info_from_pom(pom_file, dep)
      pom = XmlSimple.xml_in(pom_file.read, { 'ForceArray' => false })

      name = pom['name']
      dep.store('summary', name) unless name.nil?

      description = pom['description']
      dep.store('description', description) unless description.nil?

      url = pom['url']
      dep.store('homepage', url) unless url.nil?
    end
  end
end
