class DataUpload < ApplicationRecord
  has_one_attached :file

  UPLOADERS = %w[
    Litigations
  ].freeze

  belongs_to :uploaded_by, class_name: 'AdminUser', optional: true

  validates :file, attached: true, content_type: {in: ['text/csv']}
  validates :uploader, inclusion: {in: UPLOADERS}

  before_create :set_uploaded_by

  def uploaded_at
    created_at
  end

  def to_s
    "#{uploader} upload - id: #{id}"
  end

  private

  def set_uploaded_by
    self.uploaded_by = Current.admin_user
    true
  end
end
