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

      CaseStudy.destroy_all

      CaseStudy.create!(
        organization: 'The church of England Pensions Board',
        text: 'is using FTSE Russell and TPI data to create a new climate index.',
        link: 'https://example.com'
      ).logo.attach(attachable_file('church_of_england.png'))
      CaseStudy.create!(
        organization: 'Robeco',
        text: 'is using TPI data to guide its engagements on climate change.',
        link: 'https://example.com'
      ).logo.attach(attachable_file('robeco.png'))
      CaseStudy.create!(
        organization: 'Brunel',
        text: 'is using TPI data to shape portfolio construction in its Global High Alpha strategy.',
        link: 'https://example.com'
      ).logo.attach(attachable_file('brunel.png'))

      TPIPage.find_by(title: 'Disclaimer').update!(menu: :about)
    end
  end

  def attachable_file(filename)
    {
      io: File.open(Rails.root.join('lib', 'tasks', 'support', filename), 'r'),
      filename: File.basename(filename),
      content_type: Marcel::MimeType.for(name: filename)
    }
  end
end
