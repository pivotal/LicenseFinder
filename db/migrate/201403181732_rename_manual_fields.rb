Sequel.migration do
  up do
    alter_table(:dependencies) do
      rename_column :manual,            :added_manually
      rename_column :manually_approved, :approved_manually
      rename_column :license_manual,    :license_assigned_manually
      drop_column :approval_id
    end
  end
end
