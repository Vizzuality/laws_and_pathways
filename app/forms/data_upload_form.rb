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
    imported = service.call
    self.details = service.details
    promote_errors(service.errors) unless imported

    imported
  end

  def service
    return @service if defined?(@service)

    service_class = "Upload::#{uploader}".constantize
    @service ||= service_class.new(file.download.force_encoding('UTF-8'))
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
