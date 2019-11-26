class Content < ApplicationRecord
  belongs_to :page
  has_many :images, dependent: :destroy

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :images
  end
end
