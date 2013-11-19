Sequel.migration do
  change do
    alter_table(:dependencies) do
      add_column :manually_approved, TrueClass
    end
  end
end
