Sequel.migration do
  change do
    alter_table(:dependencies) do
      add_column :license_manual, TrueClass
    end
  end
end
