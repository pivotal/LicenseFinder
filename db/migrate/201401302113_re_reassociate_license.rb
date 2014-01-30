Sequel.migration do
  up do
    LicenseFinder::DB << <<-SQL
      UPDATE dependencies
      SET license_id =
      (SELECT min(la.id)
      FROM
        license_aliases la,
        license_aliases la_orig
      WHERE
        la.name = la_orig.name AND
        la_orig.id = license_id
      LIMIT 1)
    SQL

    LicenseFinder::DB << <<-SQL
      DELETE
      FROM license_aliases
      WHERE
      id NOT IN (SELECT license_id FROM dependencies)
    SQL
  end
end
