# == Schema Information
#
# Table name: laws_sectors
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LawsSector < ApplicationRecord
  has_many :targets, foreign_key: 'sector_id'

  validates :name, presence: true, uniqueness: true
end
