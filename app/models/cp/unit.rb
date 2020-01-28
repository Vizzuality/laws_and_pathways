class CP::Unit < ActiveRecord::Base
  belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'
end
