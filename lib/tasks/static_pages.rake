namespace :static_pages do
  desc 'Scaffold static pages'
  task generate: :environment do
    pages = [
      ['overview', 'Overview of the TPI'],
      ['methodology', 'Methodology'],
      ['strategic-relationships', 'Strategic Relationships'],
      ['technical-advisory-group', 'Technical Advisory Group'],
      ['supporters', 'Supporters'],
      ['investors', 'How Investors can use TPI'],
      ['endorsements', 'Endorsements'],
      ['team', 'Team'],
      ['faq', 'FAQ'],
      ['methodology', 'Methodology'],
      ['data-background', 'Data Background']
    ]

    supporters_content = %w(partners supporters)

    pages.each do |slug, title|
      next if Page.find_by(slug: slug)

      puts "Creating page: #{slug}"
      Page.create(
        slug: slug,
        title: title,
        description: "#{title} Description goes here"
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
