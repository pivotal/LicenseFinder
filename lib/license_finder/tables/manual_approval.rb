require 'time'

module LicenseFinder
  class ManualApproval < Sequel::Model
    plugin :timestamps, update_on_create: true

    def safe_created_at
      created_at.is_a?(String) ?
        Time.parse(created_at) :
        created_at
    end
  end
end
