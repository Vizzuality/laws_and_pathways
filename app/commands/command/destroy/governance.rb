module Command
  module Destroy
    class Governance
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap do |r|
            r.discard

            r.legislations = []
          end
        end
      end
    end
  end
end
