class Publication < ApplicationRecord
  include UserTrackable
  include PublicActivityTrackable

  has_one_attached :file
  has_one_attached :thumbnail

  validates :file, attached: true
  validates_presence_of :title, :short_description, :publication_date
end
