Sequel.migration do
  change do
    alter_table(:license_aliases) do
      drop_column :manual
    end
  end
end
