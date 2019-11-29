class Page < ApplicationRecord
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  has_many :contents, dependent: :destroy
  has_many :images, through: :contents

  MENU_HEADERS = %w[
    tpi_tool
    about
  ].freeze

  validates :slug, uniqueness: true, presence: true
  validates :title, uniqueness: true, presence: true
  validates :menu, presence: true

  enum menu: array_to_enum_hash(MENU_HEADERS)

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :contents, allow_destroy: true
  end

  after_commit :reload_routes, only: [:create, :update, :destroy]

  def reload_routes
    DynamicRouter.reload
  end
end
