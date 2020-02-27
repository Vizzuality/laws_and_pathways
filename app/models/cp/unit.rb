# == Schema Information
#
# Table name: cp_units
#
#  id          :bigint           not null, primary key
#  sector_id   :bigint
#  valid_since :date
#  unit        :text             not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CP::Unit < ApplicationRecord
  belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'

  validates_presence_of :unit

  def to_s
    return "#{unit} (valid since: #{valid_since})" if valid_since.present?

    unit
  end
end
