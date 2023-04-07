# frozen_string_literal: true

require "spec_helper"

RSpec.describe DatadogCompoundMetrics::CompoundMetric do
  describe "#add_calculation/#compute" do
    let(:compound_metric) { described_class.new(:metric_name) }

    before do
      compound_metric.add_calculation(-> { 2 })
      compound_metric.add_calculation(-> { 1 })
      compound_metric.add_calculation(-> { 3 })
    end

    it "keeps all the calculations in the registry" do
      expect(compound_metric.calculations.count).to eq 3
    end

    describe "when the calculation strategy is :min" do
      before do
        compound_metric.calculation_strategy = :min
      end

      it "returns the minimum value" do
        expect(compound_metric.compute).to eq 1
      end
    end

    describe "when the calculation strategy is :max" do
      before do
        compound_metric.calculation_strategy = :max
      end

      it "returns the minimum value" do
        expect(compound_metric.compute).to eq 3
      end
    end
  end

  describe "#name" do
    subject(:name) { compound_metric.name }

    let(:compound_metric) { described_class.new(:metric_name) }

    it { is_expected.to eq :metric_name }
  end

  describe "#calculation_strategy" do
    subject(:calculation_strategy) { compound_metric.calculation_strategy }

    let(:compound_metric) do
      described_class.new(:metric_name).tap { |metric| metric.calculation_strategy = :max }
    end

    it { is_expected.to eq :max }
  end
end
