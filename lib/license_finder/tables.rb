require 'rubygems'
require 'sequel'
require LicenseFinder::Platform.sqlite_load_path

LicenseFinder::DB = Sequel.connect("#{LicenseFinder::Platform.sqlite_adapter}://#{LicenseFinder.config.database_uri}")
Sequel.extension :migration, :core_extensions
Sequel::Migrator.run(LicenseFinder::DB, LicenseFinder::ROOT_PATH.join('../db/migrate'))
