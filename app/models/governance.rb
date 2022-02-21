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

  scope :ordered_with_parent, -> { joins(:governance_type).order('governance_types.name ASC, governances.name ASC') }

  validates_presence_of :name
  validates_uniqueness_of :name, scope: [:governance_type_id], case_sensitive: false

  def self.to_select
    pluck(Arel.sql("CONCAT('[', governance_types.name, '] ', governances.name)"), :id)
  end
end
