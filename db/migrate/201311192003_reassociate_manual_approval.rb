Sequel.migration do
  up do
    LicenseFinder::DB << <<-EOS
        UPDATE dependencies
        SET manually_approved =
        (SELECT state
        FROM
          approvals
        WHERE
          approvals.id = dependencies.approval_id)
    EOS
  end
end
