# == Schema Information
#
# Table name: governance_types
#
#  id           :bigint           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

class GovernanceType < ApplicationRecord
  include DiscardableModel

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :governances
end
