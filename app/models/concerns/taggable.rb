# To tag your model with let's say 'keywords', you need to
#
# 1) update target model
#
#  class Post < ApplicationRecord
#    include Taggable
#    tag_with :keywords
#  end
#
# 2) add new Tag subclass
#
#  class Keyword < Tag
#  end
#
# Now you can:
#
#  post = Post.create(keywords: [Keyword.create!(name: 'books')])
#  post.keywords_list # => ["books"]
#  post.keywords_list = ["sport", "holidays"]
#  post.save
#  post.keywords_list # => ["sport", "holidays"]
#  post.keywords_string # => 'sport, holidays'
#
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

        send(
          "#{name}=",
          array
            .map(&:strip)
            .reject(&:blank?)
            .uniq
            .map { |group| tag_class.find_or_initialize_by(name: group) }
        )
      end

      define_method("#{name}_string") do
        send("#{name}_list")&.join(', ')
      end

      alias_method "#{name}_string=", "#{name}_list="
    end
  end
end
