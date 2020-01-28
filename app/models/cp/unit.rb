class CP::Unit < ActiveRecord::Base
  belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'

  validates_presence_of :unit

  def to_s
    return "#{unit} (valid since: #{valid_since})" if valid_since.present?

    unit
  end
end
