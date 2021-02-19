require 'spec_helper'
require_relative '../../lib/unicode_fixer'

describe UnicodeFixer do
  describe 'fix_unicode_characters' do
    it 'performs correctly' do
      text = 'Text, â€žquoteâ€, Æ’'
      corrected = 'Text, „quote”, ƒ'

      expect(subject.fix_unicode_characters(text)).to eq(corrected)
    end
  end
end
