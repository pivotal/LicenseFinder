Sequel.migration do
  up do
    LicenseFinder::DB << <<-SQL
UPDATE dependencies
SET license_manual = 1
WHERE id
IN
  (SELECT d.id
  FROM dependencies d
  INNER JOIN license_aliases l
    ON d.license_id = l.id
  WHERE l.manual = 1)
    SQL
  end
end
