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
    end
  end
end
