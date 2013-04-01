Sequel.migration do
  change do
    alter_table(:dependencies) do
      set_column_allow_null :version
    end
  end
end
