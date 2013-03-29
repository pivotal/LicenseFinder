Sequel.migration do
  change do
    alter_table(:approvals) do
      drop_column :approval_type
    end

    alter_table(:licenses) do
      add_column :manual, TrueClass # i.e., keep this license eternally
    end
  end
end
