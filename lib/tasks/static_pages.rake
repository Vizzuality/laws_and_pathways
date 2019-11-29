namespace :static_pages do
  desc 'Scaffold static pages'
  task generate: :environment do
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
      next if Page.find_by(slug: slug)

      puts "Creating page: #{slug}"
      Page.create(
        slug: slug,
        title: title,
        description: "#{title} Description goes here",
        menu: menu_header
      )
    end

    supporters_content.each do |content|
      next if Content.find_by(content_type: content)

      puts "Creating content: #{content} for Supporters page"
      Content.create(
        content_type: content,
        title: content.capitalize,
        page: Page.find_by(slug: 'supporters'),
        text: 'Lorem ipsum - Content Text'
      )
    end
  end
end
