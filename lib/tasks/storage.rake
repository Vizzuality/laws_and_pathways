require "#{Rails.root}/lib/configuration_file"

namespace :storage do
  task copy_to_local: :environment do
    configs = ConfigurationFile.parse(Rails.root.join('config/storage.yml'))

    from_service = ActiveStorage::Service.configure :google, configs
    to_service   = ActiveStorage::Service.configure :local, configs

    models = ENV['MODELS'].split(',')
    names = ENV['NAMES'].split(',')

    ActiveStorage::Blob.service = from_service

    attachments = ActiveStorage::Attachment.where(record_type: models, name: names)
    puts "#{attachments.count} attachments to copy"

    ActiveStorage::Blob.where(id: attachments.pluck(:blob_id)).find_each do |blob|
      blob.open do |tf|
        checksum = blob.checksum
        to_service.upload(blob.key, tf, checksum: checksum)
        puts "#{blob.filename} file uploaded"
      end
    rescue ActiveStorage::FileNotFoundError
      puts "#{blob.filename} file not found"
    end
  end
end
