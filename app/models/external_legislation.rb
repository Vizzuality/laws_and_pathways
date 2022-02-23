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
  include DirtyAssociations

  has_and_belongs_to_many :litigations, after_add: :mark_changed, after_remove: :mark_changed
  belongs_to :geography

  validates_presence_of :name
  validates :url, url: true

  def display_name
    ["#{name} (id: #{id})", geography&.name].join(' | ')
  end

  alias_attribute :title, :name
end
