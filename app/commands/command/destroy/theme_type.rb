module Command
  module Destroy
    class ThemeType
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap do |r|
            r.discard

            r.themes = []
          end
        end
      end
    end
  end
end
