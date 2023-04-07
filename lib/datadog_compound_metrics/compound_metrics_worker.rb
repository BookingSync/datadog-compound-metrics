# frozen_string_literal: true

class DatadogCompoundMetrics
  class CompoundMetricsWorker
    include Sidekiq::Worker

    sidekiq_options queue: :default

    delegate :configuration, :compound_metrics, to: DatadogCompoundMetrics
    delegate :datadog_statsd_client, to: :configuration

    def perform
      compound_metrics.each do |metric|
        datadog_statsd_client.gauge(metric.name.to_s, metric.compute)
      end
    end
  end
end
