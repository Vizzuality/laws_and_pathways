module VisibilityStatus
  extend ActiveSupport::Concern

  VISIBILITY = %w[draft pending published archived].freeze

  included do
    scope :not_archived, -> { where.not(visibility_status: 'archived') }

    enum visibility_status: array_to_enum_hash(VISIBILITY)

    validates_presence_of :visibility_status
    validates :visibility_status, inclusion: {in: VISIBILITY}
  end
end
