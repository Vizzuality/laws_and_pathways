class DevTasks
  include Rake::DSL

  def initialize
    namespace :dev do
      desc 'attach random images to publications'
      task publication_images: :environment do
        unless Rails.env.development?
          puts 'THIS TASK CAN RUN ONLY IN DEVELOPMENT'
          abort
        end

        Publication.find_each do |publication|
          publication.update!(image: attachable_file(random_image_file))
        end
      end
    end
  end

  private

  def seed_file(filename)
    File.open(Rails.root.join('db', 'seeds', 'tpi', filename), 'r')
  end

  def random_image_file
    %w[
      files/airlines2022.jpg
      files/autos2022.jpg
      files/bridge.jpg
      files/industrials.jpg
      files/shipping2022.jpg
    ].sample
  end

  def attachable_file(filename)
    {
      io: seed_file(filename),
      filename: File.basename(filename),
      content_type: Marcel::MimeType.for(name: filename)
    }
  end
end

DevTasks.new
