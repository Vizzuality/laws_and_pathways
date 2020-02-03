class TPISectorCluster < ApplicationRecord
  has_many :sectors, class_name: 'TPISector', foreign_key: :cluster_id, inverse_of: :cluster

  validates_presence_of :name
end
