module CP
  class Alignment
    CP_ALIGNMENT_STANDARIZE_MAP = {
      '2 degrees (high efficiency)' => 'below 2 degrees',
      '2 degrees (shift-improve)' => '2 degrees',
      'international pledges' => 'Paris pledges'
    }.freeze

    CP_ALIGNMENT_COLORS = {
      'below 2 degrees' => {
        'paper/aluminium/cement/steel' => '#00C170', # green
        'rest' => '#FFDD49' # yellow
      },
      '2 degrees (high efficiency)' => '#00C170', # green
      '1.5 degrees' => '#00C170', # green
      '2 degrees (shift-improve)' => '#FFDD49', # yellow
      '2 degrees' => '#FFDD49', # yellow
      'paris pledges' => '#FF9600', # orange,
      'international pledges' => '#FF9600', # orange
      'not aligned' => '#ED3D4A', # red
      'no or unsuitable disclosure' => '#595B5D' # black
    }.freeze

    DEFAULT_COLOR = '#595B5D'.freeze # black

    CP_ALIGNMENT_NEW_COLORS = {
      '1.5 degrees' => '#00C170', # green
      'below 2 degrees' => '#FFDD49', # yellow
      'national pledges' => '#FF9600', # orange,
      'not aligned' => '#ED3D4A', # red
      'no or unsuitable disclosure' => '#595B5D' # black
    }.freeze

    NAMES = [
      '1.5 Degrees',
      'Not Aligned',
      'Paris Pledges',
      'Below 2 Degrees',
      '2 Degrees',
      'No or unsuitable disclosure',
      '2 Degrees (Shift-Improve)',
      'Interational Pledges',
      '2 Degrees (High Efficiency)',
      'National Pledges'
    ].freeze

    OLD_NAMES_MAP = {
      'No Disclosure' => 'No or unsuitable disclosure'
    }.freeze

    ORDER = [
      '1.5 degrees',
      'below 2 degrees',
      'national pledges',
      '2 degrees',
      'paris pledges',
      'not aligned',
      'no or unsuitable disclosure'
    ].freeze

    include ActiveModel::Model

    attr_accessor :name, :sector

    def standarized_name
      CP::Alignment.format_name((CP_ALIGNMENT_STANDARIZE_MAP[name.downcase] || name))
    end

    def formatted_name
      CP::Alignment.format_name(name)
    end

    def color
      color = CP_ALIGNMENT_COLORS[formatted_name.downcase]
      return color unless color.is_a?(Hash)

      sector_key = sector&.downcase || 'rest'

      color.select { |k| k.include?(sector_key) }.values.first || DEFAULT_COLOR
    end

    # makes sure to format names based on the standarized NAMES array
    def self.format_name(name)
      return unless name.present?

      name = OLD_NAMES_MAP[name] || name
      NAMES.find { |n| n.downcase == name.downcase } || name
    end
  end
end
