class Page < ApplicationRecord
  has_many :contents

  validates :slug, uniqueness: true, presence: true
  validates :title, presence: true

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :contents
  end

  after_save :reload_routes

  def reload_routes
    DynamicRouter.reload
  end
end
