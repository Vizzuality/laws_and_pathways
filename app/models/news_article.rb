class NewsArticle < ApplicationRecord
  include UserTrackable
  include PublicActivityTrackable

  ARTICLE_TYPES = [
    'Announcement',
    'Commentaries',
    'In the news',
    'Press Releases'
  ].freeze

  enum article_type: array_to_enum_hash(ARTICLE_TYPES)

  validates_presence_of :title, :content
end
