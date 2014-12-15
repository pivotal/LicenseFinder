Sequel.migration do
  change do
    alter_table(:dependencies) do
      add_column :missing, TrueClass
    end
  end
end
