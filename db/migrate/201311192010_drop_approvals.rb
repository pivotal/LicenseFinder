Sequel.migration do
  change do
    drop_table(:approvals)
  end
end
