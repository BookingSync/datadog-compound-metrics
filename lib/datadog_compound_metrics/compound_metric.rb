# frozen_string_literal: true

class DatadogCompoundMetrics
  class CompoundMetric
    attr_reader :name, :calculations
    attr_accessor :calculation_strategy

    def initialize(name)
      @name = name
      @calculations = []
    end

    def add_calculation(calculation)
      calculations << calculation
    end

    def compute
      calculations
        .map(&:call)
        .public_send(calculation_strategy)
    end
  end
end
