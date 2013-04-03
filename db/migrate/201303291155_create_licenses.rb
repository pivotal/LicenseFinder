Sequel.migration do
  change do
    create_table(:licenses) do
      primary_key :id
      String :name, null: false
      String :url
    end

    alter_table(:dependencies) do
      add_column :license_id, Integer
    end
  end
end
