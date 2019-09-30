require_relative '../country_iso_mapper'

namespace :flags do
  desc 'Generate Flags'
  task generate: :environment do
    destination_dir = Rails.root.join('app/assets/images/flags')
    source_dir = Dir[Rails.root.join('node_modules/svg-country-flags/svg/*.svg')]

    Dir.mkdir(destination_dir) unless Dir.exist?(destination_dir)

    source_dir.each do |filepath|
      extension = File.extname(filepath)
      alpha2 = File.basename(filepath, extension)
      alpha3 = CountryISOMapper.alpha2_to_alpha3(alpha2)

      if alpha3.nil?
        puts "Couldn't find country by alpha2: #{alpha2}"
      else
        FileUtils.cp(filepath, "#{destination_dir}/#{alpha3}#{extension}")
      end
    end
  end
end
