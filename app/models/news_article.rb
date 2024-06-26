# == Schema Information
#
# Table name: news_articles
#
#  id                :bigint           not null, primary key
#  title             :string
#  content           :text
#  publication_date  :datetime
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_insight        :boolean          default(FALSE)
#  short_description :text
#  is_event          :boolean          default(FALSE)
#

class NewsArticle < ApplicationRecord
  include UserTrackable
  include PublicActivityTrackable
  include Taggable
  include ImageWithThumb

  tag_with :keywords

  has_and_belongs_to_many :tpi_sectors

  scope :published, -> { where('publication_date <= ?', DateTime.now) }
  scope :insights, -> { where(is_insight: true) }
  scope :events, -> { where(is_event: true) }
  scope :not_insights, -> { where(is_insight: false) }
  scope :not_events, -> { where(is_event: false) }

  validates_presence_of :title, :content, :publication_date

  def self.search(query)
    where('title ilike ? OR content ilike ? OR short_description ilike ?',
          "%#{query}%", "%#{query}%", "%#{query}%")
  end

  def tags_and_sectors
    (keywords.map(&:name) + tpi_sectors.map(&:name)).compact.uniq.sort
  end
end
