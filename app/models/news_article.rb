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

  has_one_attached :thumbnail
  has_one_attached :image

  validates :image, attached: true

  ARTICLE_TYPES = [
    'Announcement',
    'Commentaries',
    'In the news',
    'Press Releases'
  ].freeze

  enum article_type: array_to_enum_hash(ARTICLE_TYPES)

  validates_presence_of :title, :content
end
