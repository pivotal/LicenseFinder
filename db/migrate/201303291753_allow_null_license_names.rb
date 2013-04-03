Sequel.migration do
  change do
    alter_table(:licenses) do
      set_column_allow_null :name
    end
  end
end
