namespace :onetime do
  desc 'Deploy new version of homepage content'
  task homepage: :environment do
    ActiveRecord::Base.transaction do
      homepage = TPIPage.find_by(slug: 'homepage-content')
      homepage.contents.destroy_all
      homepage.contents.create!(
        title: 'The TPI Global Climate Transition Centre',
        code: 'hero',
        text: '
          Transition Pathway Initiative (TPI) Global Climate Transition Centre is an authoritative,
          independent source of research and data into the progress being made by the financial and
          corporate world in making the transition to a low-carbon economy
        '
      )
      homepage.contents.create!(
        title: 'Combined AUM',
        code: 'combined_aum',
        text: '$45tn'
      )
      homepage.contents.create!(
        title: 'Sectors',
        code: 'sectors',
        text: '$45tn'
      )
      homepage.contents.create!(
        title: 'Total Market Cap',
        code: 'total_market_cap',
        text: '$10tn'
      )
    end
  end
end
