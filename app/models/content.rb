# == Schema Information
#
# Table name: contents
#
#  id           :bigint           not null, primary key
#  title        :string
#  text         :text
#  page_id      :bigint           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  content_type :string
#  position     :integer
#

class Content < ApplicationRecord
  acts_as_list scope: [:page_id]

  belongs_to :page
  has_many :images, dependent: :destroy

  CONTENT_TYPES = %w[regular text_description logo_description].freeze

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :images
  end
end
