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
      'no disclosure' => '#191919' # black
    }.freeze

    ORDER = ['below 2 degrees', '2 degrees', 'paris pledges', 'not aligned', 'no disclosure'].freeze

    include ActiveModel::Model

    attr_accessor :name

    def standarized_name
      (CP_ALIGNMENT_STANDARIZE_MAP[name.downcase] || name).titleize
    end

    def color
      CP_ALIGNMENT_COLORS[standarized_name.downcase]
    end
  end
end
