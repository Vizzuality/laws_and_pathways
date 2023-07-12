module Command
  # Representing a process of uploading a CSV file into the system.
  # It consists of:
  # - parsing uploaded CSV file
  # - creating/updating related DB records (via one of <CSVImport::*> service)
  # - storing other metadata related with the upload (as <DataUpload> record)
  #
  class CSVDataUpload
    include ActiveModel::Model

    attr_reader :data_upload
    attr_reader :uploaded_csv_file

    delegate :id, :details, :file, :file=, :details=, :uploader, :uploader=, to: :data_upload

    validate :validate_data_upload

    def initialize(attributes)
      @data_upload = ::DataUpload.new
      @uploaded_csv_file = attributes[:file]

      super(attributes)
    end

    def call
      return false if invalid?

      result = false
      ActiveRecord::Base.transaction do
        imported = import_data
        data_upload.save! if imported
        result = imported
      end

      result
    end

    def full_error_messages
      errors.full_messages.join(', ')
    end

    private

    def importer_name
      uploader
    end

    def import_data
      imported = import_service.call
      self.details = import_service.import_results
      promote_errors(import_service.errors) unless imported

      imported
    end

    def import_service
      @import_service ||= CSVImport.const_get(importer_name).new(uploaded_csv_file, rollback_on_error: true)
    rescue NameError
      raise "Can't find 'CSVImport::#{importer_name}' importer service class!"
    end

    def validate_data_upload
      promote_errors(data_upload.errors) if data_upload.invalid?
    end

    def promote_errors(child_errors)
      child_errors.each do |error|
        errors.add(error.attribute, error.message)
      end
    end
  end
end
