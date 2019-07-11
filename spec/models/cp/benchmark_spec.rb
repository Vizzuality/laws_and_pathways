# == Schema Information
#
# Table name: cp_benchmarks
#
#  id         :bigint(8)        not null, primary key
#  sector_id  :bigint(8)
#  date       :date             not null
#  benchmarks :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe CP::Benchmark, type: :model do
  subject { build(:cp_benchmark) }

  it { is_expected.to be_valid }

  it 'should be invalid without sector' do
    subject.sector = nil
    expect(subject).to have(1).errors_on(:sector)
  end

  it 'should be invalid if date is nil' do
    subject.date = nil
    expect(subject).to have(1).errors_on(:date)
  end
end
