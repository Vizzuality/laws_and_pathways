# == Schema Information
#
# Table name: governances
#
#  id                 :bigint           not null, primary key
#  name               :string
#  governance_type_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#

class Governance < ApplicationRecord
  include DiscardableModel

  belongs_to :governance_type
  has_and_belongs_to_many :legislations

  validates_presence_of :name
end
