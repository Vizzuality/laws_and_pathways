# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class DocumentType < Tag
  DOCUMENT_TYPES = [
    'All',
    'Accord',
    'Act',
    'action plan',
    'case',
    'Constitution',
    'Decree',
    'Decree law',
    'Decree/order/ordinance',
    'Directive',
    'EU decision',
    'EU directive',
    'EU regulation',
    'Framework',
    'Law',
    'NAPAs',
    'Out of date',
    'Plan',
    'Policy',
    'Programme',
    'Roadmap',
    'Regulation/rules',
    'Resolution',
    'Road map/vision',
    'Road map/vision/agenda',
    'Royal decree',
    'Strategy'
  ].freeze

  validates :name, inclusion: {in: DOCUMENT_TYPES}
end
