# Wrapper around Discard::Model with:
# - default scope changed to exclude discarded records
# - additional :all_discarded scope
#
#   class Post
#     include Discardable
#   end
#
#   Post.all           # => [post1]
#   Post.all_discarded # => []
#
#   post1.discard
#   Post.all           # => []
#   Post.all_discarded # => [post1]
#
# More details: https://github.com/jhawthorn/discard#default-scope
#
module Discardable
  extend ActiveSupport::Concern

  included do
    include Discard::Model

    default_scope -> { kept }
    scope :all_discarded, -> { with_discarded.discarded }
  end
end
