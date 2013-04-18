Sequel.migration do
  change do
    alter_table(:dependencies) do
      add_column :manual, TrueClass # i.e., keep this dependency eternally
    end
  end
end
