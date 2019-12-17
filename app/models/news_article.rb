# == Schema Information
#
# Table name: news_articles
#
#  id               :bigint           not null, primary key
#  title            :string
#  content          :text
#  publication_date :date
#  created_by_id    :bigint
#  updated_by_id    :bigint
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  article_type     :string
#

class NewsArticle < ApplicationRecord
  include UserTrackable
  include PublicActivityTrackable
  include Taggable
  include ImageWithThumb

  ARTICLE_TYPES = [
    'Announcement',
    'Commentaries',
    'In the news',
    'Press Releases'
  ].freeze

  tag_with :keywords

  enum article_type: array_to_enum_hash(ARTICLE_TYPES)

  has_and_belongs_to_many :tpi_sectors

  validates_presence_of :title, :content

  def self.search(query)
    where('title ilike ? OR content ilike ?',
          "%#{query}%", "%#{query}%")
  end

  def tags_and_sectors
    (keywords.map(&:name) + tpi_sectors.map(&:name)).compact.uniq.sort
  end
end
