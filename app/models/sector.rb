# == Schema Information
#
# Table name: sectors
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Sector < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :companies
end
