# sequel -m db/migrate -E sqlite://doc/dependencies.db

Sequel.migration do
  change do
    create_table(:dependencies) do
      primary_key :id
      String :name, null: false
      String :version, null: false
      String :summary
      String :description
      String :homepage
    end
  end
end
