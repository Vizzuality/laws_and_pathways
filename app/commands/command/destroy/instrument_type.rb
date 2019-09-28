module Command
  module Destroy
    class InstrumentType
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap(&:discard)
        end
      end
    end
  end
end
