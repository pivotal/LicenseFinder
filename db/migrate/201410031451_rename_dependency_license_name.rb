Sequel.migration do
  up do
    rename_column :dependencies, :license_name, :license_names
    run %Q{UPDATE dependencies SET license_names='["' || license_names || '"]'}
  end
end
