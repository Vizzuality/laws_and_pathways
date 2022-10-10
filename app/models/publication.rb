# == Schema Information
#
# Table name: publications
#
#  id                :bigint           not null, primary key
#  title             :string
#  short_description :text
#  file              :bigint
#  image             :bigint
#  publication_date  :datetime
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  author            :string
#

class Publication < ApplicationRecord
  include UserTrackable
  include PublicActivityTrackable
  include Taggable
  include ImageWithThumb

  has_one_attached :file
  has_one_attached :author_image

  tag_with :keywords

  has_and_belongs_to_many :tpi_sectors

  scope :published, -> { where('publication_date <= ?', DateTime.now) }

  validates :file, attached: true
  validates_presence_of :title, :short_description, :publication_date

  def self.search(query)
    where('title ilike ? OR short_description ilike ?',
          "%#{query}%", "%#{query}%")
  end

  def tags_and_sectors
    (keywords.map(&:name) + tpi_sectors.map(&:name)).compact.uniq.sort
  end

  def author_image_thumbnail
    author_image.present? ? author_image.variant(resize_to_fill: [40, 40]) : nil
  end
end
