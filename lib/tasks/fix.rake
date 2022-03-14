require_relative '../unicode_fixer'

namespace :fix do
  desc 'Fixing weird characters'
  task characters: :environment do
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
      UnicodeFixer::BROKEN_CHAR_MAP.each do |wrong, right|
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

  task trix_outer_div: :environment do
    for_real = ENV['FOR_REAL'] == 'true'

    puts 'Stripping outer divs placed by trix editor'
    # just use before_validation code to strip outer div
    ActiveRecord::Base.transaction do
      puts 'Legislations...'
      Legislation.find_each do |l|
        l.save!(touch: false)
      end

      puts 'Litigations...'
      Litigation.find_each do |l|
        l.save!(touch: false)
      end

      puts 'Geographies...'
      Geography.find_each do |g|
        g.save!(touch: false)
      end

      puts 'Targets...'
      Target.find_each do |t|
        t.save!(touch: false)
      end

      raise ActiveRecord::Rollback unless for_real
    end

    puts 'Stripping outer divs placed by trix editor' if for_real
    puts 'Rollback' unless for_real
  end

  private

  def update_all(model, attribute, wrong, right)
    klass = model.constantize
    found = klass.where("#{attribute} LIKE '%#{wrong}%'").pluck(:id)
    puts "Found #{found.count} #{klass}:#{attribute}, ids: #{found}" if found.count.positive?
    klass.update_all("#{attribute} = REPLACE(#{attribute}, '#{wrong}', '#{right}')")
  end
end
