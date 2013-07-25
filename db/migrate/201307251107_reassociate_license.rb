Sequel.migration do
  up do
  DB << <<EOS
UPDATE dependencies
SET license_id =
(SELECT la.id
FROM
  license_aliases la,
  license_aliases la_orig
WHERE
  la.name = la_orig.name AND
  la_orig.id = license_id
LIMIT 1)
EOS

  DB << <<CLEANUP
DELETE
FROM license_aliases
WHERE
id NOT IN (SELECT license_id FROM dependencies)
CLEANUP
  end
end
