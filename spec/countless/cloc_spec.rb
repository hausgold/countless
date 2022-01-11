# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Countless::Cloc do
  let(:path) { file_fixture('code/test.rb') }
  let(:paths) { [path] }

  describe '.stats' do
    let(:action) { described_class.stats(*paths) }

    it 'returns a Hash' do
      expect(action).to be_a(Hash)
    end

    it 'returns a hash with just the requested paths' do
      expect(action.keys).to match_array([path.to_s])
    end

    it 'returns a statistics hash per file with the relevant keys' do
      expect(action.values.first.keys).to \
        match_array(%i[blank comment code total])
    end

    it 'returns a statistics hash per file with all integer values' do
      expect(action.values.map(&:values).flatten).to all(be_a(Integer))
    end
  end

  describe '.raw_stats' do
    let(:action) { described_class.raw_stats(*paths) }

    it 'returns a Hash' do
      expect(action).to be_a(Hash)
    end

    it 'returns a hash with a header key' do
      expect(action).to include('header' => Hash)
    end

    it 'returns a hash with a SUM key' do
      expect(action).to include('SUM' => Hash)
    end

    it 'returns a hash with path as key' do
      expect(action).to include(path.to_s)
    end

    it 'returns a statistics hash per file (blank)' do
      expect(action[path.to_s]['blank']).to be > 1
    end

    it 'returns a statistics hash per file (comment)' do
      expect(action[path.to_s]['comment']).to be > 1
    end

    it 'returns a statistics hash per file (code)' do
      expect(action[path.to_s]['code']).to be > 1
    end

    it 'returns a statistics hash per file (language)' do
      expect(action[path.to_s]).to include('language' => String)
    end
  end
end
