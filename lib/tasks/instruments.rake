require 'csv'

namespace :instruments do
  desc 'Fixing instrument types and instruments'
  # rubocop:disable Layout/LineLength
  task fix_list: :environment do
    for_real = ENV['FOR_REAL'] == 'true'

    parse_csv = ->(filename) do
      strip_converter = ->(field) { field&.strip }
      CSV.parse(
        File.read(File.join(Rails.root, 'lib', 'tasks', 'support', filename)),
        headers: true,
        converters: [strip_converter],
        header_converters: :symbol
      )
    end

    final_new_instruments = []

    new_instruments_csv = parse_csv.call('new_instruments.csv')
    mapping_csv = parse_csv.call('instruments_mapping.csv')

    ActiveRecord::Base.transaction do
      Instrument.update_all('name = TRIM(name)')

      new_instruments_csv.each.with_index(2) do |row, _row_index|
        new_type_name, new_name = row[:instrument].split('|')
        new_type = InstrumentType.find_or_create_by!(name: new_type_name)

        instrument = Instrument.find_or_create_by!(instrument_type: new_type, name: new_name)
        final_new_instruments << instrument
      end

      mapping_csv.each.with_index(2) do |row, row_index|
        old_type_name, old_name = row[:old_mapping].split('|')
        new_type_name, new_name = row[:new_mapping].split('|')

        raise "Row #{row_index} Error" if [old_type_name, old_name, new_type_name, new_name].any?(&:nil?)

        old_types = InstrumentType.where(name: old_type_name)
        raise "Error more then one instrument type #{old_type_name}" if old_types.count > 1

        old_type = old_types.first
        raise "Error no instrument type #{old_type_name}" if old_type.nil?

        new_instrument = final_new_instruments.find do |ni|
          ni.instrument_type.name == new_type_name && ni.name == new_name
        end
        raise "Cannot find new instrument #{new_type_name}|#{new_name}" if new_instrument.nil?

        old_instruments = Instrument.where(instrument_type: old_type, name: old_name)
        old_instruments.each do |old_instrument|
          ActiveRecord::Base.connection.execute(
            "UPDATE instruments_legislations SET instrument_id = #{new_instrument.id} WHERE instrument_id = #{old_instrument.id}"
          )
        end
      end
      puts "Count instruments_legislations: #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM instruments_legislations').values}"
      # remove duplicates from instruments_legislations
      duplicates_query = <<-SQL
        DELETE FROM instruments_legislations a USING instruments_legislations b
        WHERE
          a.ctid < b.ctid AND
          a.legislation_id = b.legislation_id AND
          a.instrument_id = b.instrument_id
      SQL
      puts "Removing duplicates #{ActiveRecord::Base.connection.execute(duplicates_query).values}"
      puts "Count instruments_legislations: #{ActiveRecord::Base.connection.execute('SELECT COUNT(*) FROM instruments_legislations').values}"

      puts "New instruments count #{final_new_instruments.count}"

      ids = final_new_instruments.map(&:id)
      old_instruments_query = "SELECT distinct instrument_id FROM instruments_legislations where instrument_id NOT IN (#{ids.join(',')})"

      puts "Old instruments #{ActiveRecord::Base.connection.execute(old_instruments_query).values}"
      final_new_instruments.sort_by(&:instrument_type_id).each do |i|
        puts "#{i.instrument_type.name}|#{i.name}"
      end

      type_ids = final_new_instruments.map(&:instrument_type_id).uniq

      Instrument.where.not(id: ids).delete_all
      InstrumentType.where.not(id: type_ids).delete_all

      puts "Instruments in DB #{Instrument.count}"
      puts "InstrumentTypes in DB #{InstrumentType.count}"

      raise ActiveRecord::Rollback unless for_real
    end

    puts 'ALL DONE' if for_real
    puts 'ROLLBACK' unless for_real
  end
  # rubocop:enable Layout/LineLength
end
