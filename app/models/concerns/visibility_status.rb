module VisibilityStatus
  extend ActiveSupport::Concern

  VISIBILITY = %w[draft pending published archived].freeze

  included do
    scope :not_archived, -> { where.not(visibility_status: 'archived') }

    enum visibility_status: array_to_enum_hash(VISIBILITY)

    validates_presence_of :visibility_status
    validates :visibility_status, inclusion: {in: VISIBILITY}

    before_save :authorize_publication!, if: -> { publishing? || unpublishing? }
  end

  def authorize_publication!
    # skipping for all places where user is not defined
    # TODO: not a great way to do this I know
    return unless ::Current.admin_user.present?

    ::Current.admin_user.authorize!(
      :publish,
      self,
      message: "You are not authorized to publish/unpublish this #{self.class.name}"
    )
  end

  def publishing?
    published? && visibility_status_changed?
  end

  def unpublishing?
    visibility_status_was == 'published' && visibility_status_changed?
  end
end
