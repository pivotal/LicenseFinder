Sequel.migration do
  up do
    LicenseFinder::DB << <<-EOS
        UPDATE dependencies
        SET manually_approved =
        (SELECT state
        FROM
          approvals
        INNER JOIN
          dependencies
            ON approvals.id = dependencies.approval_id)
    EOS
  end
end
