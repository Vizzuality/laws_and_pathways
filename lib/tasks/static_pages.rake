namespace :static_pages do
  desc 'Scaffold static pages for TPI'
  task generate_tpi: :environment do
    MENU_HEADERS = OpenStruct.new(Hash[Page::MENU_HEADERS.map { |el| [el, el] }])

    pages = [
      ['Overview of the TPI', MENU_HEADERS.about],
      ['Strategic Relationships', MENU_HEADERS.about],
      ['Technical Advisory Group', MENU_HEADERS.about],
      ['Supporters', MENU_HEADERS.about],
      ['How Investors can use TPI', MENU_HEADERS.about],
      ['Endorsements', MENU_HEADERS.about],
      ['Team', MENU_HEADERS.about],
      ['FAQ', MENU_HEADERS.about],
      ['Methodology', MENU_HEADERS.tpi_tool],
      ['Data Background', MENU_HEADERS.tpi_tool]
    ]

    supporters_content = %w(partners supporters)

    pages.each do |title, menu_header|
      next if Page.find_by(title: title, type: 'TPIPage')

      puts "Creating page: #{title}"
      Page.create(
        title: title,
        description: "#{title} Description goes here",
        menu: menu_header,
        type: 'TPIPage'
      )
    end

    supporters_content.each do |content|
      next if Content.find_by(content_type: content)

      puts "Creating content: #{content} for Supporters page"
      Content.create(
        content_type: content,
        title: content.capitalize,
        page: Page.find_by(title: 'Supporters'),
        text: 'Lorem ipsum - Content Text'
      )
    end
  end

  desc 'Create TPI homepage content'
  task generate_tpi_homepage: :environment do
    home_title = 'Homepage content'
    if TPIPage.find_by(title: home_title)
      puts 'Homepage content for TPI already exists, aborting. To edit use admin interface'
      next
    end

    homepage = {
      title: home_title,
      menu: 'no_menu_entry',
      description: 'This page holds information that is shown on the homepage of TPI.
        Each of the content pieces are used on the homepage.
        This content is tied by the title of this page "Homepage content" which shouldn\'t change,
        as well as the order of the three content pieces available on the Content tab.',
      contents: [
        ['The TPI tool', 'The Transition Pathway Initiative (TPI) is a global, asset-owner led
          initiative which assesses companies\' preparedness for the transition to
          low carbon economy. Rapidly becoming the go-to corporate climate action benchmark,
          the TPI tool is available here.'],
        ['How investors can use the TPI', 'The TPI is designed to support investors.
          Find out how they can use its findings.'],
        ['Supporters', 'The TPI is supported globally by more than 75 investors with over
            $20.5 trillion combined Assets Under Management and Advice.']
      ]
    }
    page = TPIPage.create(
      title: homepage[:title],
      menu: homepage[:menu],
      description: homepage[:description]
    )

    homepage[:contents].each do |title, text|
      Content.create(
        title: title,
        page: page,
        text: text
      )
    end
    puts 'All done!'
  end

  desc 'Scaffold static pages for CCLOW'
  task generate_cclow: :environment do
    pages = %w[
      About
      Methodology
    ]

    pages.each do |title|
      next if Page.find_by(slug: title.downcase, type: 'CCLOWPage')

      puts "Creating CCLOW page: #{title}"
      Page.create(
        slug: title.downcase,
        title: title,
        type: 'CCLOWPage',
        menu: 'header'
      )
    end
  end
end
