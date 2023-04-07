# frozen_string_literal: true

require "active_support"
require "active_support/core_ext"
require "sidekiq"
require "sidekiq-cron"
require "zeitwerk"

loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/datadog-compound-metrics.rb")
loader.setup

class DatadogCompoundMetrics
  def self.loader
    @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
      loader.ignore("#{__dir__}/datadog-compound-metrics.rb")
    end
  end

  def self.configuration
    @configuration ||= DatadogCompoundMetrics::Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.add_compound_metric(metric_name)
    compound_metric = DatadogCompoundMetrics::CompoundMetric.new(metric_name)
    yield compound_metric
    compound_metrics << compound_metric
  end

  def self.compound_metrics
    @compound_metrics ||= []
  end

  def self.schedule_job
    Sidekiq::Cron::Job.create(
      name: "DatadogCompoundMetrics::CompoundMetricsWorker",
      cron: configuration.sidekiq_cron_schedule,
      class: "DatadogCompoundMetrics::CompoundMetricsWorker",
      queue: configuration.sidekiq_queue,
      args: [],
      active_job: false
    )
  end

  def self.reset_config
    @configuration = nil
  end

  def self.reset_metrics
    @compound_metrics = []
  end
end

DatadogCompoundMetrics.loader.setup
