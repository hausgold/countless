# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Countless::SourceStatistics do
  let(:instance) { described_class.new(*dirs) }
  let(:dirs) do
    [
      { name: 'Code', dir: 'spec/fixtures/files/code', pattern: pattern },
      { name: 'Test', dir: 'spec/fixtures/files/test', pattern: pattern,
        test: true },
      { name: 'Nothing', dir: 'spec/fixtures/empty', pattern: /\.rb$/ }
    ]
  end
  let(:pattern) { /.*/ }

  describe '#statistics' do
    let(:action) { instance.statistics }

    it 'returns a Hash' do
      expect(action).to be_a(Hash)
    end

    it 'returns a Hash with the configured names as keys' do
      expect(action.keys).to match_array(%w[Code Test Nothing])
    end

    it 'returns a Hash with the statistics present' do
      expect(action.values).to \
        all(include(stats: Countless::SourceStatistics::Calculator))
    end

    YAML.safe_load(
      file_fixture('code_statistics.yml').read,
      permitted_classes: [Symbol, Regexp]
    ).each do |name, conf|
      context "with a #{name} file" do
        let(:action) { instance.total }
        let(:pattern) { conf[:pattern] }

        it 'detected the correct amount of lines' do
          expect(action.lines).to be_eql(conf[:lines])
        end

        it 'detected the correct amount of code lines' do
          expect(action.code_lines).to be_eql(conf[:code_lines])
        end

        it 'detected the correct amount of classes' do
          expect(action.classes).to be_eql(conf[:classes])
        end

        it 'detected the correct amount of methods' do
          expect(action.methods).to be_eql(conf[:methods])
        end

        it 'calculates the correct methods per code' do
          expect(action.m_over_c).to be_eql(conf[:m_over_c])
        end

        it 'calculates the correct lines of code per method' do
          expect(action.loc_over_m).to be_eql(conf[:loc_over_m])
        end
      end
    end
  end

  describe '#total' do
    let(:action) { instance.total }

    context 'with a single configuration' do
      let(:dirs) do
        [{ name: 'Nothing', dir: 'spec/fixtures/empty', pattern: /\.rb$/ }]
      end

      it 'returns nil' do
        expect(action).to be(nil)
      end
    end

    context 'with multiple configurations' do
      let(:dirs) do
        [
          { name: 'Code', dir: 'spec/fixtures/files' },
          { name: 'Nothing', dir: 'spec/fixtures/empty' }
        ]
      end

      it 'returns a Countless::SourceStatistics::Calculator instance' do
        expect(action).to be_a(Countless::SourceStatistics::Calculator)
      end

      it 'detected the correct amount of lines' do
        expect(action.lines).to be_eql(275)
      end

      it 'detected the correct amount of code lines' do
        expect(action.code_lines).to be_eql(160)
      end

      it 'detected the correct amount of classes' do
        expect(action.classes).to be_eql(10)
      end

      it 'detected the correct amount of methods' do
        expect(action.methods).to be_eql(22)
      end

      it 'calculates the correct methods per code' do
        expect(action.m_over_c).to be_eql(2)
      end

      it 'calculates the correct lines of code per method' do
        expect(action.loc_over_m).to be_eql(7)
      end
    end
  end

  describe '#to_s' do
    let(:action) { instance.to_s }
    let(:output) do
      [
        '+---------+-------+-----+---------+---------+-----+-------+',
        '| Name    | Lines | LOC | Classes | Methods | M/C | LOC/M |',
        '+---------+-------+-----+---------+---------+-----+-------+',
        '| Code    |   213 | 114 |       7 |      11 |   1 |    10 |',
        '| Test    |    62 |  46 |       3 |      11 |   3 |     4 |',
        '| Nothing |     0 |   0 |       0 |       0 |   0 |     0 |',
        '+---------+-------+-----+---------+---------+-----+-------+',
        '| Total   |   275 | 160 |      10 |      22 |   2 |     7 |',
        '+---------+-------+-----+---------+---------+-----+-------+',
        '  Code LOC: 114     Test LOC: 46     Code to Test Ratio: 1:0.4'
      ].join("\n")
    end

    it 'returns the correct formatted output' do
      expect(action).to be_eql(output)
    end
  end

  describe '#dirs' do
    let(:action) { instance.dirs.map { |conf| conf.except(:stats) } }

    context 'when given via argument' do
      it 'returns the specified directory configurations' do
        expect(action).to match(dirs.map { |conf| conf.except(:stats) })
      end
    end

    context 'when configured' do
      let(:instance) { described_class.new }

      it 'returns the configured directory configurations' do
        expect(action).to match(Countless.configuration.stats_directories)
      end
    end
  end
end
