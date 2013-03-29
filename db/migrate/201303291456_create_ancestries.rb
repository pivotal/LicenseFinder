Sequel.migration do
  change do
    create_table(:ancestries) do
      primary_key :id
      Integer :parent_dependency_id
      Integer :child_dependency_id
    end
  end
end
