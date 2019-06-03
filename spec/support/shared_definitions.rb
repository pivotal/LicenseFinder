# frozen_string_literal: true

module SharedDefinitions
  extend RSpec::Core::SharedContext

  let(:cmd_success) { double('StatusSuccess', success?: true) }
  let(:cmd_failure) { double('StatusFailure', success?: false) }
end
