# == Schema Information
#
# Table name: laws_sectors
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  parent_id  :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class LawsSector < ApplicationRecord
  belongs_to :parent, class_name: 'LawsSector', foreign_key: 'parent_id', optional: true
  has_many :subsectors, class_name: 'LawsSector', foreign_key: 'parent_id'
  has_many :targets, foreign_key: 'sector_id'
  has_and_belongs_to_many :litigations
  has_and_belongs_to_many :legislations

  validates :name, presence: true, uniqueness: true
end
