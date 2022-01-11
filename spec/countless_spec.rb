# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Countless do
  before { described_class.reset_configuration! }

  it 'has a version number' do
    expect(Countless::VERSION).not_to be nil
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
      described_class.configuration.stats_file_extensions += ['test']
      expect { described_class.reset_configuration! }.to \
        change { described_class.configuration.stats_file_extensions }
    end
  end
end
