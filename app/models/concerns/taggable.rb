module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable
  end

  class_methods do
    def tag_with(name, **attrs)
      class_name = attrs[:class_name] || name.to_s.singularize.camelize
      has_many name, through: :taggings, source: :tag, class_name: class_name

      define_method("#{name}_list") do
        send(name).map(&:name)
      end

      define_method("#{name}_list=") do |value|
        array = value.is_a?(String) ? value.split(',') : Array.wrap(value)
        tag_class = class_name.constantize

        send("#{name}=", array.map { |group| tag_class.find_or_initialize_by(name: group) })
      end
    end
  end
end
