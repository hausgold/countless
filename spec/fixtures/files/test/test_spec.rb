# frozen_string_literal: true

class Meme
  def i_can_has_cheezburger?
    "OHAI!"
  end

  def will_it_blend?
    "YES!"
  end
end

RSpec.describe Meme do
  subject { Meme.new }

  describe '#i_can_has_cheezburger?' do
    it 'returns "OHAI!"' do
      expect(subject.i_can_has_cheezburger?).to be_eql('OHAI!')
    end
  end

  describe '#will_it_blend?' do
    it 'returns "YES!"' do
      expect(subject.will_it_blend?).to be_eql('YES!')
    end
  end

  xit 'is skipped' do
    # TODO: Do something
  end
end
