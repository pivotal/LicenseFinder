Sequel.migration do
  change do
    create_table(:approvals) do
      primary_key :id
      Boolean :state
      String :approval_type
    end

    alter_table(:dependencies) do
      add_column :approval_id, Integer
    end
  end
end
