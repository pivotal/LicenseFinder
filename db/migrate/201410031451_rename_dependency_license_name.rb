Sequel.migration do
  up do
    rename_column :dependencies, :license_name, :license_names
  end
end
