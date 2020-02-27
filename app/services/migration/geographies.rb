require 'uri'
module Migration
  class Geographies
    class << self
      def migrate_metadata_file(source)
        file = File.read(source).force_encoding('UTF-8')
        csv = CSV.parse(
          file,
          headers: true,
          skip_blanks: true
        ).delete_if { |row| row.to_hash.values.all?(&:blank?) }
        csv.each do |row|
          puts row['iso']
          g = ::Geography.where(iso: row['iso']).first
          unless g
            puts "Can't find geography with this iso: #{row['iso']}"
            next
          end
          g.percent_global_emissions = row['percent_global_emissions'].to_f.round(2).to_s
          g.climate_risk_index = row['climate_risk_index']
          g.wb_income_group = row['wb_income_group']
          g.save
        end
      end
    end
  end
end
