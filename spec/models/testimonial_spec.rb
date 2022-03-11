# == Schema Information
#
# Table name: testimonials
#
#  id         :bigint           not null, primary key
#  quote      :string
#  author     :string
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Testimonial, type: :model do
  subject { build(:testimonial) }

  it { is_expected.to be_valid }

  it 'should be invalid without author' do
    subject.author = nil
    expect(subject).to have(1).errors_on(:author)
  end

  it 'should be invalid without quote' do
    subject.quote = nil
    expect(subject).to have(1).errors_on(:quote)
  end
end
