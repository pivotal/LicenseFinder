module LicenseFinder
  module Platform
    def self.sqlite_adapter
      java? ? 'jdbc:sqlite' : 'sqlite'
    end

    def self.sqlite_gem
      java? ? 'jdbc-sqlite3' : 'sqlite3'
    end

    def self.sqlite_load_path
      java? ? 'jdbc/sqlite3' : 'sqlite3'
    end

    def self.java?
      RUBY_PLATFORM =~ /java/
    end
  end
end

