# == Schema Information
#
# Table name: instrument_types
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class InstrumentType < ApplicationRecord
  validates_presence_of :name
end
