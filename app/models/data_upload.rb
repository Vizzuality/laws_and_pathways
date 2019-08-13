class DataUpload < ApplicationRecord
  has_one_attached :file

  UPLOADERS = %w[
    Litigations
  ].freeze

  belongs_to :uploaded_by, class_name: 'AdminUser', optional: true

  validates :file, attached: true, content_type: {in: ['text/csv']}
  validates :uploader, inclusion: {in: UPLOADERS}

  before_create :import_data
  before_create :set_uploaded_by

  private

  def import_data
    service_class = "Upload::#{uploader}".constantize
    service = service_class.new(file.download.force_encoding('UTF-8'))

    imported = service.call

    unless imported
      service.errors.each do |error|
        errors.add(:base, error[:msg])
      end
    end

    imported
  end

  def set_uploaded_by
    self.uploaded_by = Current.admin_user
    true
  end
end
