require 'zip'

ActionController::Renderers.add :zip do |files, options|
  filename = options[:filename] || controller_name

  zipped_csv = Zip::OutputStream.write_buffer do |zos|
    files.each do |filename, content|
      zos.put_next_entry filename
      zos.print content
    end
  end
  zipped_csv.rewind

  send_data zipped_csv.read,
            type: Mime[:zip],
            disposition: "attachment; filename=#{filename}.zip"
end
