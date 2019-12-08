require 'uri'
module Migration
  class Legislation
    class << self
      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Style/IfUnlessModifier
      def fill_responses
        adaptation = Response.find_or_create_by(name: 'Adaptation')
        drm = Response.find_or_create_by(name: 'Disaster Risk Management')
        lad = Response.find_or_create_by(name: 'Loss and Damage')
        mitigation = Response.find_or_create_by(name: 'Mitigation')

        ::Legislation.all.each do |l|
          responses = []
          if l.keywords.map { |t| t.name&.downcase }.include?('adaptation')
            responses << adaptation
          end
          text = [l.title, l.frameworks, l.keywords_string, l.description].flatten.join(',')

          terms = %w[Disaster DRM DRR]
          if terms.map(&:downcase).any? { |word| text.include?(word) }
            responses << drm
          end

          text = [l.title, l.description].join(',')
          terms = ['Loss and Damage', 'Loss & Damage', 'Warsaw Mechanism']
          if terms.map(&:downcase).any? { |word| text.include?(word) }
            responses << lad
          end

          terms = %w[Carbon Energy LULUCF Mitigation REDD Transportation Waste]
          if (terms.map(&:downcase) & l.keywords.map { |t| t.name&.downcase }).any?
            responses << mitigation
          end

          l.responses = responses
          l.save
        end
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Style/IfUnlessModifier

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
          l = ::Legislation.where(id: row['law_id']).first
          unless l
            puts "Can't find law with this Id: #{row['law_id']}"
            next
          end
          source = row['url']
          doc = Document.new(name: row['title'],
                             last_verified_on: row['date'],
                             language: row['language'])
          if row['url'].include?('http://www.lse.ac.uk/GranthamInstitute/wp-content/uploads')
            doc.type = 'uploaded'
            if for_real
              begin
                filename = File.basename(URI.parse(source).path)
                file = URI.open(source)
              rescue URI::InvalidURIError, OpenURI::HTTPError, OpenSSL::SSL::SSLError
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
