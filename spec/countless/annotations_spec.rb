# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Countless::Annotations do
  let(:instance) { described_class.new }

  describe '#annotations' do
    let(:action) { instance.annotations }
    let(:mapped_action) do
      action.map do |filename, annotations|
        annotations.map do |annotation|
          [filename, annotation.to_h]
        end
      end.flatten(1)
    end
    let(:annotations) do
      [
        [
          'Rakefile',
          { line: 7, tag: 'TODO', text: 'This is just for testing purposes' }
        ],
        [
          'lib/countless/rake_tasks.rb',
          { line: 3, tag: '@TODO', text: 'This is just for testing purposes ' \
                                         'here. Keep it exactly like that.' }
        ],
        [
          'spec/fixtures/files/test/test_spec.rb',
          { line: 29, tag: 'TODO', text: 'Do something' }
        ]
      ]
    end

    it 'returns a hash' do
      expect(action).to be_a(Hash)
    end

    it 'returns a hash with Annotation values' do
      expect(action.values.flatten).to \
        all(be_a(Countless::Annotations::Annotation))
    end

    it 'returns the correct annotations' do
      expect(mapped_action).to match_array(annotations)
    end
  end

  describe '#to_s' do
    let(:action) { instance.to_s }
    let(:output) do
      [
        'Rakefile:',
        '  * [ 7] This is just for testing purposes',
        '',
        'lib/countless/rake_tasks.rb:',
        '  * [ 3] This is just for testing purposes here. Keep it exactly ' \
        'like that.',
        '',
        'spec/fixtures/files/test/test_spec.rb:',
        '  * [29] Do something',
        ''
      ].join("\n")
    end

    it 'returns the correct formatted output' do
      expect(action).to be_eql(output)
    end
  end
end
