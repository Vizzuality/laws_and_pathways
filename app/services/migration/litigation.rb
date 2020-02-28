require 'uri'
module Migration
  class Litigation
    class << self
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def migrate_source_files(source)
        for_real = Rails.env.staging?
        file = File.read(source).force_encoding('UTF-8')
        csv = CSV.parse(
          file,
          headers: true,
          skip_blanks: true
        ).delete_if { |row| row.to_hash.values.all?(&:blank?) }

        # clear Case Documents before import, for cases in the file
        d = ::Document
          .where(documentable_id: csv.map { |g| g['case_id'] }.uniq,
                 documentable_type: 'Litigation', name: 'Case document')
        puts "Deleting #{d.size} case documents"
        d.delete_all

        csv.each do |row|
          l = ::Litigation.where(id: row['case_id']).first
          unless l
            puts "Can't find litigation with this Id: #{row['case_id']}"
            next
          end
          next unless row['url'].present?

          source = row['url']
          doc = Document.new(name: row['title'],
                             last_verified_on: row['date'],
                             language: row['language'])
          # if row['url'].include?('http://www.lse.ac.uk/GranthamInstitute/wp-content/uploads')
          doc.type = 'uploaded'
          if for_real
            begin
              filename = File.basename(URI.parse(source).path)
              file = URI.open(source)
            rescue URI::InvalidURIError, OpenURI::HTTPError, OpenSSL::SSL::SSLError, Errno::ENOENT
              puts "File for #{row['case_id']}, #{row['title']}, and #{row['url']} not working"
              next
            end
            doc.file.attach(io: file, filename: filename.last)
          end
          # else
          #   doc.type = 'external'
          #   doc.external_url = row['url']
          # end
          l.documents << doc if for_real
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength
    end
  end
end
