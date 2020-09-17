namespace :fix do
  # rubocop:disable Layout/HashAlignment
  desc 'Fixing weird characters'
  task characters: :environment do
    chars_map = {
      'â‚¬' => '€',
      'â€š' => ',',
      'Æ’'  => 'ƒ',
      'â€ž' => '„',
      'â€¦' => '…',
      'Ë†'  => 'ˆ',
      'â€°' => '‰',
      'â€¹' => '‹',
      'â€˜' => '‘',
      'â€™' => '’',
      'â€œ' => '“',
      'â€¢' => '•',
      'â€“' => '–',
      'â€”' => '—',
      'Ëœ'  => '˜',
      'â„¢' => '™',
      'â€º' => '›',
      'â€'  => '”',
      'Â°'  => '°',
      'Â¸'  => '¸',
      'Â§'  => '§',
      'Â¬'  => '-',
      'Â£'  => '£',
      'Â«'  => '«',
      'Â»'  => '»',
      'Â®'  => '®',
      'Â©'  => '©',
      'Â²'  => '²',
      'Â³'  => '³',
      'Âµ'  => 'µ',
      'Â´'  => '´',
      'Â'   => '',
      'Ã±'  => 'ñ',
      'Ã¡'  => 'á',
      'Ã¢'  => 'â',
      'Ã£'  => 'ã',
      'Ã¤'  => 'ä',
      'Ã§'  => 'ç',
      'Ã¨'  => 'è',
      'Ã©'  => 'é',
      'Ãª'  => 'ê',
      'Ã´'  => 'ô',
      'Ã³'  => 'ó',
      'Ã¶'  => 'ö',
      'Ãº'  => 'ú',
      'Ã¼'  => 'ü',
      'Ã«'  => 'ë',
      'Ã '  => 'à'
    }

    ActiveRecord::Base.transaction do
      chars_map.each do |wrong, right|
        puts "Searching for #{wrong} and replacing with #{right}"

        update_all(Company, :name, wrong, right)
        update_all(Company, :latest_information, wrong, right)
        update_all(Geography, :federal_details, wrong, right)
        update_all(Geography, :legislative_process, wrong, right)

        update_all(Litigation, :title, wrong, right)
        update_all(Litigation, :summary, wrong, right)
        update_all(Litigation, :at_issue, wrong, right)
        update_all(Legislation, :title, wrong, right)
        update_all(Legislation, :description, wrong, right)
        update_all(Target, :description, wrong, right)
        update_all(Document, :name, wrong, right)
        update_all(ExternalLegislation, :name, wrong, right)
        update_all(Event, :title, wrong, right)
      end

      raise ActiveRecord::Rollback if ENV['DRY_RUN']
    end
  end
  # rubocop:enable Layout/HashAlignment

  private

  def update_all(klass, attribute, wrong, right)
    found = klass.where("#{attribute} LIKE '%#{wrong}%'").pluck(:id)
    puts "Found #{found.count} #{klass}:#{attribute}, ids: #{found}" if found.count.positive?
    klass.update_all("#{attribute} = REPLACE(#{attribute}, '#{wrong}', '#{right}')")
  end
end
