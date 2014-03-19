module LicenseFinder
  class ManualApproval < Sequel::Model
    plugin :timestamps, update_on_create: true
  end
end
