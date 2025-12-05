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
#  code         :string
#

class Content < ApplicationRecord
  acts_as_list scope: [:page_id]

  belongs_to :page
  has_many :images, dependent: :destroy, inverse_of: :content

  CONTENT_TYPES = %w[regular text_description logo_description].freeze

  with_options allow_destroy: true, reject_if: :all_blank do
    accepts_nested_attributes_for :images
  end

  def removeable?
    code.nil?
  end

  def simple_text?
    %w[
      total_market_cap
      sectors
      supporters_without_logo
      combined_aum
      methodology_publication_id
      cp_methodology_publication_id
      corporate_management_quality
      corporate_carbon_performance
    ].include? code
  end

  def static_content?
    %w[
      total_market_cap
      sectors
      supporters_without_logo
      combined_aum
      methodology_description
      methodology_publication_id
      cp_methodology_publication_id
      corporate_management_quality
      corporate_carbon_performance
    ].include? code
  end
end
