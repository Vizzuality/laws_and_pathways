require 'uri'
module Migration
  class Litigation
    class << self
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def migrate_source_files(source)
        for_real = Rails.env.production?
        file = File.read(source).force_encoding('UTF-8')
        csv = CSV.parse(
          file,
          headers: true,
          skip_blanks: true
        ).delete_if { |row| row.to_hash.values.all?(&:blank?) }
        csv.each do |row|
          l = ::Litigation.where(id: row['case_id']).first
          unless l
            puts "Can't find litigation with this Id: #{row['case_id']}"
            next
          end
          next unless row['url'].present?

          puts "Found--> #{l.title}"
          source = row['url']
          puts "url to get the file from --> #{source}"
          doc = Document.new(name: row['title'],
                             last_verified_on: row['date'],
                             language: row['language'])
          if row['url'].include?('http://www.lse.ac.uk/GranthamInstitute/wp-content/uploads')
            doc.type = 'uploaded'
            if for_real
              puts 'Now we are really getting the file'
              filename = File.basename(URI.parse(source).path)
              begin
                file = URI.open(source)
              rescue URI::InvalidURIError
                puts "File for #{row['law_id']} and #{row['url']} not working"
                next
              end
              doc.file.attach(io: file, filename: filename.last)
            end
          else
            doc.type = 'external'
            doc.external_url = row['url']
          end
          l.documents << doc
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
