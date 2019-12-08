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
#

class Page < ApplicationRecord
  extend FriendlyId

  friendly_id :title, use: :slugged, routes: :default

  has_many :contents, dependent: :destroy
  has_many :images, through: :contents

  validates :menu, presence: true

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :contents, allow_destroy: true
  end

  after_commit :reload_routes, only: [:create, :update, :destroy]

  def reload_routes
    DynamicRouter.reload
  end
end
