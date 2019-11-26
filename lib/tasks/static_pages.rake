namespace :static_pages do
  desc 'Scaffold static pages'
  task generate: :environment do
    pages = %w(methodology supporters)

    supporters_content = %w(partners supporters)

    pages.each do |page|
      next if Page.find_by(slug: page)

      puts "Creating page: #{page}"
      Page.create(
        slug: page,
        title: page.capitalize,
        description: 'Lorem ipsum - Page subtitle'
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
