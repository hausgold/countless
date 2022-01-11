# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Countless::Extensions::ConfigurationHandling do
  let(:described_class) { Countless }

  before { described_class.reset_configuration! }

  it 'allows the access of the configuration' do
    expect(described_class.configuration).not_to be_nil
  end

  describe '.configure' do
    it 'yields the configuration' do
      expect do |block|
        described_class.configure(&block)
      end.to yield_with_args(described_class.configuration)
    end
  end

  describe '.reset_configuration!' do
    it 'resets the configuration to its defaults' do
      described_class.configuration.cloc_path = '/bin/true'
      expect { described_class.reset_configuration! }.to \
        change { described_class.configuration.cloc_path }
    end
  end

  describe '.statistic_directories' do
    it 'generates the same result on subsequent calls' do
      expect(described_class.statistic_directories).to \
        match(described_class.statistic_directories)
    end
  end
end
