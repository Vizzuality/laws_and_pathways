# == Schema Information
#
# Table name: companies
#
#  id                      :bigint(8)        not null, primary key
#  location_id             :bigint(8)
#  headquarter_location_id :bigint(8)
#  sector_id               :bigint(8)
#  name                    :string           not null
#  slug                    :string           not null
#  isin                    :string           not null
#  size                    :string
#  ca100                   :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'rails_helper'

RSpec.describe Company, type: :model do
  subject { build(:company) }

  it { is_expected.to be_valid }
end
