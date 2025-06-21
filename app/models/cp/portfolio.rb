module CP
  class Portfolio
    NAMES_WITH_CATEGORIES = {
      'Consumer Lending' => [
        'Auto Loans (retail)',
        'Mortgages (retail)'
      ],
      'Corporate and Commercial Banking' => [
        'General Purpose Finance & Business Lending',
        'Project Finance'
      ],
      'Investment Banking and Capital Markets' => [
        'Private Debt & Equity',
        'Listed Debt & Equity',
        'Debt & Equity Facilitating',
        'Advisory Services (e.g. M&A)',
        'Derivatives & Structured Products',
        'Treasury & Payments',
        'Sales & Trading (including market trading)'
      ],
      'Asset & Wealth Management' => [
        'Asset & Wealth Management (including private banking)',
      ],
      'Insurance' => [
        'Insurance'
      ]
    }.freeze
    NAMES = NAMES_WITH_CATEGORIES.values.flatten.freeze
    NAME_MAP = {
      'Auto Loans (retail)' => 'Auto Loans',
      'Mortgages (retail)' => 'Mortgages',
      'General Purpose Finance & Business Lending' => 'Corporate lending',
      'Project Finance' => 'Project finance',
      'Private Debt & Equity' => 'Sales & Trading (market-making for securities & client assets)',
      'Advisory Services (e.g. M&A)' => 'M&A Advisory',
      'Listed Debt & Equity' => 'Listed Debt & Equity',
      'Debt & Equity Facilitating' => 'Debt & Equity Facilitating',
      'Derivatives & Structured Products' => 'Derivatives',
      'Treasury & Payments' => 'Treasury & Risk Management',
      'Sales & Trading (including market trading)' => 'Commodities',
      'Asset & Wealth Management (including private banking)' => 'All wealth and asset management activities (including private banking) across all asset classes',
      'Insurance' => 'Insurance'
    }.freeze
  end
end
