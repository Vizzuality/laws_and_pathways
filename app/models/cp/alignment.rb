module CP
  class Alignment
    CP_ALIGNMENT_STANDARIZE_MAP = {
      '2 degrees (high efficiency)' => 'below 2 degrees',
      '2 degrees (shift-improve)' => '2 degrees',
      'international pledges' => 'Paris pledges'
    }.freeze

    CP_ALIGNMENT_COLORS = {
      'below 2 degrees' => '#00C170', # green
      '2 degrees' => '#FFDD49', # yellow
      'paris pledges' => '#FF9600', # orange,
      'not aligned' => '#ED3D4A', # red
      'no or unsuitable disclosure' => '#595B5D' # black
    }.freeze

    NAMES = [
      'Not Aligned',
      'Paris Pledges',
      'Below 2 Degrees',
      '2 Degrees',
      'No or unsuitable disclosure',
      '2 Degrees (Shift-Improve)',
      'Interational Pledges',
      '2 Degrees (High Efficiency)'
    ].freeze

    OLD_NAMES_MAP = {
      'No Disclosure' => 'No or unsuitable disclosure'
    }.freeze

    ORDER = ['below 2 degrees', '2 degrees', 'paris pledges', 'not aligned', 'no or unsuitable disclosure'].freeze

    include ActiveModel::Model

    attr_accessor :name

    def standarized_name
      CP::Alignment.format_name((CP_ALIGNMENT_STANDARIZE_MAP[name.downcase] || name))
    end

    def color
      CP_ALIGNMENT_COLORS[standarized_name.downcase]
    end

    def self.format_name(name)
      return unless name.present?

      name = OLD_NAMES_MAP[name] || name
      NAMES.find { |n| n.downcase == name.downcase } || name
    end
  end
end
