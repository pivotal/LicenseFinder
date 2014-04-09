Sequel.migration do
  up do
    alter_table(:dependencies) do
      add_column :license_name, String
    end

    LicenseFinder::DB << <<-SQL
      UPDATE dependencies
      SET license_name =
      (SELECT name
      FROM
        license_aliases
      WHERE
        license_id = license_aliases.id)
    SQL

    alter_table(:dependencies) do
      drop_column :license_id
    end

    drop_table(:license_aliases)
  end
end
