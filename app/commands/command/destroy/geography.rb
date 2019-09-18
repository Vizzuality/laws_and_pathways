module Command
  module Destroy
    class Geography
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap do |r|
            r.discard
            r.events.discard_all

            r.litigations = []
            r.legislations = []
          end
        end
      end
    end
  end
end
