# == Schema Information
#
# Table name: subsectors
#
# id         :bigint           not null, primary key
# sector_id  :bigint           not null
# name       :string           not null
# created_at :datetime         not null
# updated_at :datetime         not null
#
class Subsector < ApplicationRecord
  belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'
  has_many :cp_assessments

  validates :name, presence: true
  validates :name, uniqueness: {scope: :sector_id}
end
