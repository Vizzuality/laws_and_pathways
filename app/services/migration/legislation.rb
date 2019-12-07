module Migration
  class Legislation
    class << self
      # rubocop:disable Metrics/AbcSize
      def fill_responses
        ::Legislation.all.each do |l|
          responses = []
          responses << 'adaptation' if l.keywords.map{|t| t.name&.downcase}.include?('adaptation')

          text = [l.title, l.frameworks, l.keywords_string, l.description].flatten.join(',')

          responses << 'Disaster Risk Management' if ['Disaster', 'DRM', 'DRR'].map(&:downcase).any? { |word| text.include?(word) }

          text = [l.title, l.description].join(',')
          responses << 'Loss and Damage' if ['Loss and Damage', 'Loss & Damage', 'Warsaw Mechanism'].map(&:downcase).any? { |word| text.include?(word) }

          responses << 'Mitigation' if (['Carbon', 'Energy', 'LULUCF', 'Mitigation', 'REDD', 'Transportation', 'Waste'].map(&:downcase) & l.keywords.map{|t| t.name&.downcase}).any?
          l.save
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
