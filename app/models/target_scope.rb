# == Schema Information
#
# Table name: target_scopes
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

class TargetScope < ApplicationRecord
  include DiscardableModel

  has_many :targets

  validates_presence_of :name
end
