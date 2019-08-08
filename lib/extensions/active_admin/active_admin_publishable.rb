module ActiveAdminPublishable
  module Scopes
    def publishable_scopes
      scope('All', &:all)
      scope('Draft', &:draft)
      scope('Pending', &:pending)
      scope('Published', &:published)
      scope('Archived', &:archived)
    end

    def publishable_sidebar(*args)
      sidebar 'Publishing Status', *args do
        attributes_table do
          tag_row :visibility_status, interactive: true
        end
      end
    end
  end
end
