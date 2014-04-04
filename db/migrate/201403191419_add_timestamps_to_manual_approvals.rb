Sequel.migration do
  change do
    alter_table(:manual_approvals) do
      add_column :created_at, DateTime
      add_column :updated_at, DateTime
    end

    LicenseFinder::DB << <<-SQL
      UPDATE manual_approvals
      SET
        created_at = datetime('now'),
        updated_at = datetime('now')
    SQL
  end
end
