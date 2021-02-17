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

    model_attributes_map = {
      'Company' => [:name, :latest_information],
      'MQ::Assessment' => [:notes],
      'CP::Assessment' => [:assumptions],
      'Geography' => [:federal_details, :legislative_process],
      'Litigation' => [:title, :summary, :at_issue],
      'Legislation' => [:title, :description],
      'Target' => [:description],
      'Document' => [:name],
      'ExternalLegislation' => [:name],
      'Event' => [:title, :description]
    }

    ActiveRecord::Base.transaction do
      chars_map.each do |wrong, right|
        puts "Searching for #{wrong} and replacing with #{right}"

        model_whitelist = ENV['MODELS']&.split(',') || model_attributes_map.keys
        model_attributes_map
          .select { |model| model_whitelist.include?(model) }
          .map do |model, attributes|
            attributes.each { |attribute| update_all(model, attribute, wrong, right) }
          end
      end

      raise ActiveRecord::Rollback if ENV['DRY_RUN']
    end
  end
  # rubocop:enable Layout/HashAlignment

  private

  def update_all(model, attribute, wrong, right)
    klass = model.constantize
    found = klass.where("#{attribute} LIKE '%#{wrong}%'").pluck(:id)
    puts "Found #{found.count} #{klass}:#{attribute}, ids: #{found}" if found.count.positive?
    klass.update_all("#{attribute} = REPLACE(#{attribute}, '#{wrong}', '#{right}')")
  end
end
