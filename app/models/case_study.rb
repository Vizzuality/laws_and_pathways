# == Schema Information
#
# Table name: case_studies
#
#  id           :bigint           not null, primary key
#  organization :string           not null
#  link         :string
#  text         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class CaseStudy < ApplicationRecord
  has_one_attached :logo

  validates_presence_of :organization, :text
  validates :link, url: true

  def to_s
    organization
  end
end
