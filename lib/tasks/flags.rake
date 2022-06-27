require_relative '../country_iso_mapper'
require 'open-uri'

namespace :flags do
  desc 'Generate Flags'
  task generate: :environment do
    destination_dir = Rails.root.join('app/assets/images/flags')
    repo = 'madebybowtie/FlagKit'
    path = 'Assets/SVG'
    client = Octokit::Client.new

    Dir.mkdir(destination_dir)

    flags = client.contents(repo, path: path)

    flags.each do |flag|
      puts "Copying flag #{flag[:name]}"
      download_url = flag[:download_url]

      alpha2, extension = flag[:name].split('.')
      alpha3 = CountryISOMapper.alpha2_to_alpha3(alpha2)

      if alpha3.nil?
        puts "Couldn't find country by alpha2: #{alpha2}"
      else
        URI.parse(download_url).open do |image|
          File.open("#{destination_dir}/#{alpha3}.#{extension}", 'wb') do |file|
            file.write(image.read)
          end
        end
      end
    end
  end
end
