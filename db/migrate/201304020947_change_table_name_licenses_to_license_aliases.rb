Sequel.migration do
  change do
    rename_table(:licenses, :license_aliases)
  end
end
