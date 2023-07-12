module CP
  class Portfolio
    NAMES_WITH_CATEGORIES = {
      'Mortgages' => [
        'Mortgages'
      ],
      'Auto Loans' => [
        'Auto Loans'
      ],
      'Corporate Banking' => [
        'Corporate lending',
        'Project finance'
      ],
      'Investment Banking and Capital Markets Activities' => [
        'Sales & Trading (market-making for securities & client assets)',
        'M&A Advisory',
        'Debt & Equity Facilitating',
        'Derivatives',
        'Commodities',
        'Treasury & Risk Management'
      ],
      'Asset Management' => [
        'All wealth and asset management activities (including private banking) across all asset classes'
      ]
    }.freeze
    NAMES = NAMES_WITH_CATEGORIES.values.flatten.freeze
  end
end
