module LicenseFinder
  module Platform
    def self.sqlite_adapter
      if java?
        'jdbc:sqlite'
      else
        'sqlite'
      end
    end

    def self.sqlite_gem
      if java?
        'jdbc-sqlite3'
      else
        'sqlite3'
      end
    end

    def self.sqlite_load_path
      if java?
        'jdbc/sqlite3'
      else
        'sqlite3'
      end
    end

    def self.java?
      RUBY_PLATFORM =~ /java/
    end
  end
end

