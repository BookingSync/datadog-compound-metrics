# frozen_string_literal: true

class DatadogCompoundMetrics
  class Configuration
    attr_accessor :datadog_statsd_client, :sidekiq_queue, :sidekiq_cron_schedule
  end
end
