# == Schema Information
#
# Table name: target_scopes
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TargetScope < ApplicationRecord
  include Discardable

  has_many :targets

  validates_presence_of :name
end
