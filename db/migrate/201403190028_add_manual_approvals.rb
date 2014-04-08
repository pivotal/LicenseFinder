Sequel.migration do
  up do
    create_table(:manual_approvals) do
      primary_key :id
      foreign_key :dependency_id, :dependencies, unique: true, on_delete: :cascade
      String :approver, null: true
      String :notes, null: true
    end

    LicenseFinder::DB << <<-SQL
      INSERT INTO manual_approvals
        (dependency_id)
      SELECT id
      FROM dependencies
      WHERE approved_manually;
    SQL

    alter_table(:dependencies) do
      drop_column :approved_manually
    end
  end
end
