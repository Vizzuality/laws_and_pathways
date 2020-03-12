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
  has_many :sectors, class_name: 'TPISector', foreign_key: :cluster_id, inverse_of: :cluster

  validates_presence_of :name
end
