module Publishable
  extend ActiveSupport::Concern

  VISIBILITY = %w[draft pending published archived].freeze

  included do
    enum visibility_status: array_to_enum_hash(VISIBILITY)

    validates_presence_of :visibility_status
  end
end
