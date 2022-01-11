# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Countless do
  before { described_class.reset_configuration! }

  it 'has a version number' do
    expect(Countless::VERSION).not_to be nil
  end
end
