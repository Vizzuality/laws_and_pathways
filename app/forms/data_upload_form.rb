class DataUploadForm
  include ActiveModel::Model

  attr_reader :data_upload

  delegate :id, :file, :file=, :details, :details=, :uploader, :uploader=, to: :data_upload
  validate :validate_data_upload

  def initialize(attributes)
    @data_upload = DataUpload.new

    super(attributes)
  end

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      imported = import_data
      data_upload.save! if imported

      return imported
    end

    false
  end

  private

  def import_data
    imported = import_service.call
    self.details = import_service.import_results
    promote_errors(import_service.errors) unless imported

    imported
  end

  def import_service
    return @import_service if defined?(@import_service)

    service_class = "CSVImport::#{uploader}".constantize
    @import_service ||= service_class.new(file.download.force_encoding('UTF-8'))
  end

  def validate_data_upload
    promote_errors(data_upload.errors) if data_upload.invalid?
  end

  def promote_errors(child_errors)
    child_errors.each do |attribute, message|
      errors.add(attribute, message)
    end
  end
end
