class CaseStudy < ApplicationRecord
  has_one_attached :logo

  validates_presence_of :organization, :link, :text
  validates :link, url: true

  def to_s
    organization
  end
end
