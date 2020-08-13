# == Schema Information
#
# Table name: instruments
#
#  id                 :bigint           not null, primary key
#  name               :string
#  instrument_type_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#

class Instrument < ApplicationRecord
  include DiscardableModel

  belongs_to :instrument_type
  has_and_belongs_to_many :legislations

  scope :ordered_with_parent, -> { includes(:instrument_type).order('instrument_types.name ASC, instruments.name ASC') }

  validates_presence_of :name

  def self.to_select
    pluck(Arel.sql("CONCAT('[', instrument_types.name, '] ', instruments.name)"), :id)
  end
end
