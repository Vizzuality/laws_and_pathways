require 'rails_helper'

RSpec.describe CP::Benchmark, type: :model do
  subject { build(:cp_benchmark) }

  it { is_expected.to be_valid }
end
