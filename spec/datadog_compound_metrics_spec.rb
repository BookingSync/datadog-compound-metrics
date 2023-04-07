# frozen_string_literal: true

require "spec_helper"

RSpec.describe DatadogCompoundMetrics do
  it "has a version number" do
    expect(DatadogCompoundMetrics::VERSION).not_to be_nil
  end

  describe "configuration" do
    subject(:configuration) { described_class.configuration }

    before do
      described_class.configure do |config|
        config.datadog_statsd_client = :datadog_statsd_client
        config.sidekiq_queue = :critical
        config.sidekiq_cron_schedule = "*/5 * * * * *"
      end
    end

    it "allows to configure the gem" do
      expect(configuration.datadog_statsd_client).to eq(:datadog_statsd_client)
      expect(configuration.sidekiq_queue).to eq(:critical)
      expect(configuration.sidekiq_cron_schedule).to eq("*/5 * * * * *")
    end
  end

  describe "compound metrics" do
    subject(:add_metric) do
      described_class.add_compound_metric(:metric_name) do |metric|
        metric.add_calculation(-> { 2 })
        metric.add_calculation(-> { 1 })
        metric.add_calculation(-> { 3 })
        metric.calculation_strategy = :min
      end
    end

    let(:compound_metric) { described_class.compound_metrics.first }

    it "allows to add compound metrics" do
      expect do
        add_metric
      end.to change { described_class.compound_metrics.count }.from(0).to(1)

      expect(compound_metric.name).to eq :metric_name
      expect(compound_metric.compute).to eq 1
    end
  end

  describe ".schedule_job" do
    subject(:schedule_job) { described_class.schedule_job }

    let(:created_job) { Sidekiq::Cron::Job.all.first }

    before do
      described_class.configure do |config|
        config.sidekiq_cron_schedule = "*/10 * * * * *"
        config.sidekiq_queue = :critical
      end
    end

    around do |example|
      Sidekiq.redis(&:flushall)

      example.run

      Sidekiq.redis(&:flushall)
    end

    it "schedules DatadogCompoundMetrics::CompoundMetricWorker" do
      expect do
        schedule_job
      end.to change { Sidekiq::Cron::Job.all.count }.from(0).to(1)

      expect(created_job.name).to eq("DatadogCompoundMetrics::CompoundMetricWorker")
      expect(created_job.cron).to eq("*/10 * * * * *")
      expect(created_job.klass).to eq("DatadogCompoundMetrics::CompoundMetricWorker")
      expect(created_job.queue_name_with_prefix).to eq("critical")
      expect(created_job.args).to eq([])
      expect(created_job).not_to be_is_active_job
    end

    context "when called twice" do
      before do
        described_class.schedule_job
      end

      it "does not create duplicates" do
        expect do
          schedule_job
        end.not_to change { Sidekiq::Cron::Job.all.count }
      end
    end
  end
end
