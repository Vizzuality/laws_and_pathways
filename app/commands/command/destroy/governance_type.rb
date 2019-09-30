module Command
  module Destroy
    class GovernanceType
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap do |r|
            r.discard

            r.governances = []
          end
        end
      end
    end
  end
end
