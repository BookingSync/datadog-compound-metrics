# DatadogCompoundMetrics

A gem for building compound metric (a single metric from multiple ones). Mostly to have a single metric do Horizontal Pod Autoscaling for workers consuming from multiple queues.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add datadog-compound-metrics

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install datadog-compound-metrics

## Usage


In the initializer:


``` rb
Rails.application.config.to_prepare do
  DatadogCompoundMetrics.configure do |config|
    config.datadog_statsd_client = Datadog::Statsd.new(ENV.fetch("DD_AGENT_HOST"), ENV.fetch("DATADOG_PORT"), namespace: "app_name.production", tags: ["host:disabled"]) # required
    config.sidekiq_queue = :critical # required
    config.sidekiq_cron_schedule = "*/10 * * * * *" # required, you can also use extended syntax covering seconds
  end

  DatadogCompoundMetrics.add_compound_metric("sidekiq.autoscaling.high_concurrency_worker") do |compound_metric|
    compound_metric.add_calculation(-> { Sidekiq::Queue.new("queue_1").latency })
    compound_metric.add_calculation(-> { Sidekiq::Queue.new("queue_2").latency })
    # to have a single metric taking the maximum from these latencies:
    compound_metric.calculation_strategy = :max # :min/:max, in the end it's going to be a method call on the Array
  end


  Sidekiq.configure_server do |config|
    config.on(:startup) do
      DatadogCompoundMetrics.schedule_job # add it to cron jobs
    end
  end
  # remember also to tweak cron poll interval if you are planning to use extended syntax covering seconds and schedule jobs more often
  Sidekiq::Options[:cron_poll_interval] = 10
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/BookingSync/datadog-compound-metrics.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
