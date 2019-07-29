module Import
  class LocationUtils
    class << self
      def find_by_iso(country_iso)
        Location.find_by!(iso: country_iso)
      rescue StandardError
        puts "Couldn't find Location with ISO: #{country_iso}"
      end
    end
  end
end
