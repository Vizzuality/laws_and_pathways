module Import
  class GeographyUtils
    class << self
      def find_by_iso(country_iso)
        Geography.find_by!(iso: country_iso)
      rescue StandardError
        puts "Couldn't find Geography with ISO: #{country_iso}"
      end
    end
  end
end
