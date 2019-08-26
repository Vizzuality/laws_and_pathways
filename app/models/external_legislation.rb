# == Schema Information
#
# Table name: external_legislations
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  url          :string
#  geography_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class ExternalLegislation < ApplicationRecord
  has_and_belongs_to_many :litigations
  belongs_to :geography

  validates_presence_of :name
  validates :url, url: true
end
