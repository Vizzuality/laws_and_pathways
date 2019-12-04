module ImageWithThumb
  extend ActiveSupport::Concern

  included do
    has_one_attached :image
  end

  def thumbnail
    image.present? ? image.variant(resize: '400x400') : nil
  end
end
