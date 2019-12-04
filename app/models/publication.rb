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
end
