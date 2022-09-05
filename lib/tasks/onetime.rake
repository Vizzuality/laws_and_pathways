class OneTimeTasks
  include Rake::DSL

  def initialize
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
            text: 'is using FTSE Russell and TPI data to create a new climate index.'
          ).logo.attach(attachable_file('church_of_england.png'))
          CaseStudy.create!(
            organization: 'abrdn',
            text: 'is using TPI data to identify transition leaders and laggards.',
            link: page_link('case-study-helping-abrdn-challenge-transition-laggards-and-identify-transition-leaders')
          ).logo.attach(attachable_file('ABRDN.png'))
          CaseStudy.create!(
            organization: 'Robeco',
            text: 'is using TPI data to guide its engagements on climate change.',
            link: page_link('case-study-helping-robeco-drive-down-emissions-in-the-auto-industry')
          ).logo.attach(attachable_file('robeco.png'))
          CaseStudy.create!(
            organization: 'Länsförsäkringar',
            text: 'is using TPI data to inform its exclusion and climate transition lists',
            link: page_link('case-study-helping-lansforsakringar-define-companies-in-transition')
          ).logo.attach(attachable_file('Lans.png'))
          CaseStudy.create!(
            organization: 'Brunel',
            text: 'is using TPI data to shape portfolio construction in its Global High Alpha strategy.',
            link: page_link('case-study-helping-brunel-raise-climate-standards-across-the-finance-industry')
          ).logo.attach(attachable_file('brunel.png'))
          CaseStudy.create!(
            organization: 'USS',
            text: 'is using TPI data to inform voting and engagement decisions.',
            link: page_link('case-study-helping-uss-vote-on-climate-management')
          ).logo.attach(attachable_file('USS.png'))

          TPIPage.find_by(title: 'Disclaimer').update!(menu: :about)
          TPIPage.find_by(title: 'FAQ').update!(menu: :no_menu_entry)

          Keyword.find_or_create_by!(name: 'Event')
          ascor = Keyword.find_or_create_by!(name: 'ASCOR')
          Publication.find(84).keywords << ascor
          Publication.find(105).keywords << ascor

          tpi_companies_page = TPIPage
            .create_with(menu: :no_menu_entry)
            .find_or_create_by!(title: 'Publicly listed equities content', slug: 'publicly-listed-equities-content')

          tpi_companies_page.contents.destroy_all
          tpi_companies_page.contents.create!(
            title: 'Methodology',
            code: 'methodology_description',
            text: 'TODO: define Methodology description'
          )

          tpi_banks_page = TPIPage
            .create_with(menu: :no_menu_entry)
            .find_or_create_by!(title: 'Banks content', slug: 'banks-content')

          tpi_banks_page.contents.destroy_all
          tpi_banks_page.contents.create!(
            title: 'Methodology',
            code: 'methodology_description',
            text: 'TODO: define Methodology description'
          )
        end
      end
    end
  end

  private

  def page_link(slug)
    domain = Rails.configuration.try(:tpi_domain)

    "https://#{domain}/#{slug}"
  end

  def attachable_file(filename)
    {
      io: File.open(Rails.root.join('lib', 'tasks', 'support', filename), 'r'),
      filename: File.basename(filename),
      content_type: Marcel::MimeType.for(name: filename)
    }
  end
end

OneTimeTasks.new
