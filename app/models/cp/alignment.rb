module CP
  class Alignment
    CP_ALIGNMENT_STANDARIZE_MAP = {
      '2 degrees (high efficiency)' => 'below 2 degrees',
      '2 degrees (shift-improve)' => '2 degrees',
      'international pledges' => 'Paris pledges'
    }.freeze

    CP_ALIGNMENT_COLORS = {
      'below 2 degrees' => {
        'paper/aluminium' => '#00C170', # green
        'rest' => '#FFDD49' # yellow
      },
      '2 degrees (high efficiency)' => '#00C170', # green
      '1.5 degrees' => '#00C170', # green
      '2 degrees (shift-improve)' => '#FFDD49', # yellow
      '2 degrees' => '#FFDD49', # yellow
      'paris pledges' => '#FF9600', # orange,
      'national pledges' => '#FF9600', # orange
      'international pledges' => '#FF9600', # orange
      'not aligned' => '#ED3D4A', # red
      'no or unsuitable disclosure' => '#595B5D', # black
      'no disclosure' => '#595B5D', # black
      'not assessable using tpi’s methodology' => '#CFD7ED' # grey
    }.freeze

    DEFAULT_COLOR = '#595B5D'.freeze # black

    NAMES = [
      '1.5 Degrees',
      '2 Degrees (High Efficiency)',
      'Below 2 Degrees',
      '2 Degrees',
      '2 Degrees (Shift-Improve)',
      'Paris Pledges',
      'International Pledges',
      'National Pledges',
      'Not Aligned',
      'No or unsuitable disclosure',
      'No disclosure',
      'Not Assessed',
      'Not assessable using TPI’s methodology'
    ].freeze
    ALLOWED_NAMES = NAMES

    OLD_NAMES_MAP = {
      'No Disclosure' => 'No or unsuitable disclosure'
    }.freeze

    include ActiveModel::Model

    attr_accessor :name, :sector

    def standarized_name
      CP::Alignment.format_name((CP_ALIGNMENT_STANDARIZE_MAP[name.downcase] || name))
    end

    def formatted_name
      CP::Alignment.format_name(name)
    end

    alias to_s formatted_name

    def not_assessed?
      to_s.downcase == 'not assessed'
    end

    def color
      color = CP_ALIGNMENT_COLORS[formatted_name.downcase]
      return color unless color.is_a?(Hash)

      sector_key = sector&.downcase || 'rest'

      default_value = color['rest'] || DEFAULT_COLOR
      color.select { |k| k.include?(sector_key) }.values.first || default_value
    end

    # makes sure to format names based on the standarized NAMES array
    def self.format_name(name)
      return unless name.present?

      name = OLD_NAMES_MAP[name] || name
      NAMES.find { |n| n.downcase == name.downcase } || name
    end
  end
end
