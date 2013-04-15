require 'rubygems'
require 'sequel'
require LicenseFinder::Platform.sqlite_load_path

DB = Sequel.connect(URI.escape("#{LicenseFinder::Platform.sqlite_adapter}://#{LicenseFinder.config.database_path}"))
Sequel.extension :migration, :core_extensions
Sequel::Migrator.run(DB, LicenseFinder::ROOT_PATH.join('../db/migrate'))
