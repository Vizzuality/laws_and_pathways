# == Schema Information
#
# Table name: tpi_sector_clusters
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TPISectorCluster < ApplicationRecord
  INDUSTRY_AND_MATERIALS_SECTORS = [
    'Aluminium',
    'Cement',
    'Chemicals',
    'Diversified Mining',
    'Paper',
    'Steel'
  ].freeze

  has_many :sectors, class_name: 'TPISector', foreign_key: :cluster_id, inverse_of: :cluster

  validates_presence_of :name

  def slug
    name.parameterize
  end

  def display_name
    industry_cluster? ? 'Industrials and Materials' : name
  end

  def sectors_count_for_display
    industry_cluster? ? INDUSTRY_AND_MATERIALS_SECTORS.size : sectors.count
  end

  def sector_names_for_display
    industry_cluster? ? INDUSTRY_AND_MATERIALS_SECTORS : sectors.map(&:name).sort
  end

  private

  def industry_cluster?
    ['Industry', 'Industrials and Materials'].include?(name) ||
      %w[industry industrials-and-materials].include?(slug)
  end
end
