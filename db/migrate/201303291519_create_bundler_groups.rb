Sequel.migration do
  change do
    create_table(:bundler_groups) do
      primary_key :id
      String :name
    end

    create_table(:bundler_groups_dependencies) do
      Integer :bundler_group_id
      Integer :dependency_id
    end
  end
end
