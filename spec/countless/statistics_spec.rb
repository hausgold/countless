# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Countless::Statistics do
  let(:instance) { described_class.new(*dirs) }
  let(:dirs) do
    [
      { name: 'Code', pattern: 'spec/fixtures/files/code/**/*' },
      { name: 'Test', pattern: 'spec/fixtures/files/test/**/*', test: true },
      { name: 'Nothing', pattern: 'spec/fixtures/empty/**/*' }
    ]
  end

  describe '#statistics' do
    let(:action) { instance.statistics }

    it 'returns a Hash' do
      expect(action).to be_a(Hash)
    end

    it 'returns a Hash with the configured names as keys' do
      expect(action.keys).to match_array(%w[Code Test])
    end

    it 'returns a Hash with the statistics present' do
      expect(action.values).to \
        all(include(stats: Countless::Statistics::Calculator))
    end

    YAML.safe_load(
      file_fixture('code_statistics.yml').read
    ).each do |name, raw_conf|
      context "with a #{name} file" do
        let(:action) { instance.statistics['Code'][:stats] }
        let(:conf) { raw_conf.symbolize_keys }
        let(:dirs) do
          [
            {
              name: 'Code',
              pattern: "spec/fixtures/files/#{conf[:pattern]}"
            }
          ]
        end

        it 'detected the correct amount of lines' do
          expect(action.lines).to be_eql(conf[:lines])
        end

        it 'detected the correct amount of code lines' do
          expect(action.code_lines).to be_eql(conf[:code_lines])
        end

        it 'detected the correct amount of comment lines' do
          expect(action.comment_lines).to be_eql(conf[:comment_lines])
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
        [{ name: 'Nothing', pattern: 'spec/fixtures/empty/*' }]
      end

      it 'returns nil' do
        expect(action).to be_nil
      end
    end

    context 'with multiple configurations' do
      let(:dirs) do
        [
          { name: 'Code', pattern: 'spec/fixtures/files/code/**/*' },
          { name: 'Test', pattern: 'spec/fixtures/files/test/**/*',
            test: true }
        ]
      end

      it 'returns a Countless::Statistics::Calculator instance' do
        expect(action).to be_a(Countless::Statistics::Calculator)
      end

      it 'detected the correct amount of lines' do
        expect(action.lines).to be_eql(348)
      end

      it 'detected the correct amount of code lines' do
        expect(action.code_lines).to be_eql(203)
      end

      it 'detected the correct amount of comment lines' do
        expect(action.comment_lines).to be_eql(89)
      end

      it 'detected the correct amount of classes' do
        expect(action.classes).to be_eql(11)
      end

      it 'detected the correct amount of methods' do
        expect(action.methods).to be_eql(30)
      end

      it 'calculates the correct methods per code' do
        expect(action.m_over_c).to be_eql(2)
      end

      it 'calculates the correct lines of code per method' do
        expect(action.loc_over_m).to be_eql(6)
      end
    end
  end

  describe '#to_s' do
    let(:action) { instance.to_s }
    let(:output) do
      [
        '+-------+-------+-----+----------+---------+---------+-----+-------+',
        '| Name  | Lines | LOC | Comments | Classes | Methods | M/C | LOC/M |',
        '+-------+-------+-----+----------+---------+---------+-----+-------+',
        '| Code  |   286 | 157 |       86 |       8 |      19 |   2 |     8 |',
        '| Test  |    62 |  46 |        3 |       3 |      11 |   3 |     4 |',
        '+-------+-------+-----+----------+---------+---------+-----+-------+',
        '| Total |   348 | 203 |       89 |      11 |      30 |   2 |     6 |',
        '+-------+-------+-----+----------+---------+---------+-----+-------+',
        '  Code LOC: 157     Test LOC: 46     Code to Test Ratio: 1:0.3'
      ].join("\n")
    end

    it 'returns the correct formatted output' do
      expect(action).to eql(output)
    end
  end

  describe '#dirs' do
    let(:action) { instance.dirs.map { |conf| conf.except(:stats, :files) } }

    context 'when given via argument' do
      it 'returns the specified directory configurations' do
        expect(action).to \
          match(dirs.map { |conf| conf.except(:stats) }[0..1])
      end
    end

    context 'when configured' do
      let(:instance) { described_class.new }
      let(:config) do
        Countless.statistic_directories.find do |cur|
          cur[:dir] == File.join(Countless.configuration.base_path, 'lib')
        end
      end

      it 'returns the configured directory configurations' do
        expect(action.first).to include(config)
      end
    end
  end
end
