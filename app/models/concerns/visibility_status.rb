module VisibilityStatus
  extend ActiveSupport::Concern

  VISIBILITY = %w[draft pending published archived].freeze

  included do
    scope :not_archived, -> { where.not(visibility_status: 'archived') }

    enum visibility_status: array_to_enum_hash(VISIBILITY)

    validates_presence_of :visibility_status
    validates :visibility_status, inclusion: {in: VISIBILITY}

    validate :user_can_publish, if: -> { publishing? || unpublishing? }
  end

  def user_can_publish
    # skipping for all places where user is not defined
    # TODO: not a great way to do this I know
    return unless ::Current.admin_user.present?
    return if ::Current.admin_user.can?(:publish, self)

    errors.add(:base, 'You are not authorized to publish/unpublish this Entity')
  end

  def publishing?
    published? && visibility_status_changed?
  end

  def unpublishing?
    visibility_status_was == 'published' && visibility_status_changed?
  end
end
