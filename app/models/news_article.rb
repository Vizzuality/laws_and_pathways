class NewsArticle < ApplicationRecord
  include UserTrackable
  include PublicActivityTrackable

  validates_presence_of :title, :content
end
