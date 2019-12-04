class Publication < ApplicationRecord
  include UserTrackable
  include PublicActivityTrackable
  include Taggable

  has_one_attached :file
  has_one_attached :image

  tag_with :keywords
  validates :file, attached: true

  validates_presence_of :title, :short_description, :publication_date

  def thumbnail
    image.present? ? image.variant(resize: '400x400') : nil
  end
end
