module CommonPathHelper
  def self.shortest_common_paths(paths)
    [].tap do |common_paths|
      # organize by matching root paths
      paths_with_roots = paths.group_by { |path| path.split('/').first }
      paths_with_roots.each do |common_root, full_paths|
        # use the shortest path as the 'template'
        shortest_path = full_paths.sort_by { |path| path.split('/').length }.first
        shortest_common_path = common_root

        # iterate through each subpath of the 'template'
        shortest_path.split('/').each_with_index do |subpath, i|
          potential_path = i.zero? ? shortest_common_path : [shortest_common_path, subpath].join('/')

          # check each for the existence of the subsequent subpath
          mismatch = full_paths.any? { |path| !path.start_with?(potential_path) }
          break if mismatch

          shortest_common_path = potential_path
        end
        common_paths << shortest_common_path
      end
    end
  end
end
