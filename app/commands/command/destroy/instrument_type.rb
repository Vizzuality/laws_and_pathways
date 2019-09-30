module Command
  module Destroy
    class InstrumentType
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap do |r|
            r.discard

            r.instruments = []
          end
        end
      end
    end
  end
end
