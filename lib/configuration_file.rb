class ConfigurationFile # :nodoc:
  class FormatError < StandardError; end

  def initialize(content_path)
    @content_path = content_path.to_s
    @content = read content_path
  end

  def self.parse(content_path, **options)
    new(content_path).parse(**options)
  end

  def parse(context: nil, **options)
    source = render(context)
    if YAML.respond_to?(:unsafe_load)
      YAML.unsafe_load(source, **options) || {}
    else
      YAML.safe_load(source, **options) || {}
    end
  end

  private

  def read(content_path)
    require 'yaml'
    require 'erb'

    File.read(content_path).tap do |content|
      warn 'File contains invisible non-breaking spaces, you may want to remove those' if content.include?("\u00A0")
    end
  end

  def render(context)
    erb = ERB.new(@content).tap { |e| e.filename = @content_path }
    context ? erb.result(context) : erb.result
  end
end
