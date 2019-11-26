class Page < ApplicationRecord
  has_many :contents, dependent: :destroy
  has_many :images, through: :contents

  validates :slug, uniqueness: true, presence: true
  validates :title, presence: true

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :contents, allow_destroy: true
  end

  after_commit :reload_routes, :only => [:create, :update, :destroy]

  def reload_routes
    DynamicRouter.reload
  end
end
