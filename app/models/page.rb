# == Schema Information
#
# Table name: pages
#
#  id          :bigint           not null, primary key
#  title       :string
#  description :text
#  slug        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  menu        :string
#  type        :string
#  position    :integer
#

class Page < ApplicationRecord
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  acts_as_list scope: [:type, :menu]

  has_many :contents, -> { order(position: :asc) }, foreign_key: :page_id, dependent: :destroy, inverse_of: :page
  has_many :images, through: :contents

  validates :menu, presence: true

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :contents, allow_destroy: true
  end

  after_commit :reload_routes, only: [:create, :update, :destroy]

  def should_generate_new_friendly_id?
    title_changed? || super
  end

  def path
    "/#{slug}"
  end

  def reload_routes
    DynamicRouter.reload
  end
end
