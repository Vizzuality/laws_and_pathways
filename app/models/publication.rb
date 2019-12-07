# == Schema Information
#
# Table name: publications
#
#  id                :bigint           not null, primary key
#  title             :string
#  short_description :text
#  file              :bigint
#  image             :bigint
#  publication_date  :date
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sector_id         :bigint
#

class Publication < ApplicationRecord
  include UserTrackable
  include PublicActivityTrackable
  include Taggable
  include ImageWithThumb

  has_one_attached :file

  tag_with :keywords

  belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id', optional: true

  validates :file, attached: true
  validates_presence_of :title, :short_description, :publication_date

  def self.search(query)
    where('title ilike ? OR short_description ilike ?',
          "%#{query}%", "%#{query}%")
  end
end
