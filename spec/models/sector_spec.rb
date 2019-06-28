# == Schema Information
#
# Table name: sectors
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

RSpec.describe Sector, type: :model do
  subject { build(:sector) }

  it { is_expected.to be_valid }
end
