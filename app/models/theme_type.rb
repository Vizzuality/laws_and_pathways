# == Schema Information
#
# Table name: theme_types
#
#  id           :bigint           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

class ThemeType < ApplicationRecord
  include DiscardableModel

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  has_many :themes
end
