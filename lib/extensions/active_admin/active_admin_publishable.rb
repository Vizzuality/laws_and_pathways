module ActiveAdminPublishable
  module Scopes
    def publishable_scopes
      scope('All', &:all)
      scope('Draft', &:draft)
      scope('Pending', &:pending)
      scope('Published', &:published)
      scope('Archived', &:archived)
    end
  end
end
