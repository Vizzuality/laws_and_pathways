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
    has_many :tags, -> { order(:id) }, through: :taggings
  end

  class_methods do
    def tag_with(name, **attrs)
      singular_name = name.to_s.singularize
      class_name = attrs[:class_name] || singular_name.camelize

      has_many_attrs = {}
      has_many_attrs[:class_name] = class_name
      has_many_attrs[:after_add] = :mark_changed if instance_methods.include?(:mark_changed)
      has_many_attrs[:after_remove] = :mark_changed if instance_methods.include?(:mark_changed)

      has_many name, -> { order(:id) }, through: :taggings, source: :tag, **has_many_attrs

      define_method("#{singular_name}_ids=") do |value|
        super(value&.uniq)
      end

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

      define_method("#{name}_csv") do
        send("#{name}_list")&.join(Rails.application.config.csv_options[:entity_sep])
      end

      alias_method "#{name}_string=", "#{name}_list="
    end

    def with_tags_by_id(tag_ids)
      joins(:taggings).where(taggings: {tag_id: Array.wrap(tag_ids)})
    end
  end
end
