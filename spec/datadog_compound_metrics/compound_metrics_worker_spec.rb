# frozen_string_literal: true

require "spec_helper"

RSpec.describe DatadogCompoundMetrics::CompoundMetricsWorker do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    let(:datadog_statsd_client) { Datadog::Statsd.new("localhost", "8125") }

    before do
      DatadogCompoundMetrics.configure do |config|
        config.datadog_statsd_client = datadog_statsd_client
      end

      DatadogCompoundMetrics.add_compound_metric(:min_metric) do |metric|
        metric.add_calculation(-> { 2 })
        metric.add_calculation(-> { 1 })
        metric.add_calculation(-> { 3 })
        metric.calculation_strategy = :min
      end

      DatadogCompoundMetrics.add_compound_metric(:max_metric) do |metric|
        metric.add_calculation(-> { 2 })
        metric.add_calculation(-> { 1 })
        metric.add_calculation(-> { 3 })
        metric.calculation_strategy = :max
      end

      allow(datadog_statsd_client).to receive(:gauge).and_call_original
    end

    it "sends metrics to Datadog" do
      perform

      expect(datadog_statsd_client).to have_received(:gauge).with("min_metric", 1)
      expect(datadog_statsd_client).to have_received(:gauge).with("max_metric", 3)
    end
  end
end
