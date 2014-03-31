require 'rubygems'
require 'sequel'
require LicenseFinder::Platform.sqlite_load_path

module LicenseFinder
  DB = Sequel.connect(Platform.sqlite_adapter + "://" + config.artifacts.database_uri)

  Sequel.extension :migration, :core_extensions
  Sequel::Migrator.run(DB, ROOT_PATH.join('../db/migrate'))
end
