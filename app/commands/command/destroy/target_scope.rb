module Command
  module Destroy
    class TargetScope
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap do |r|
            r.discard

            r.targets = []
          end
        end
      end
    end
  end
end
