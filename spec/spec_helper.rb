# frozen_string_literal: true

require "datadog-compound-metrics"
require "datadog/statsd"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.after do
    DatadogCompoundMetrics.reset_config
    DatadogCompoundMetrics.reset_metrics
  end
end
