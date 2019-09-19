module Command
  module Destroy
    class Legislation
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap do |r|
            r.discard

            r.documents.discard_all
            r.events.discard_all

            r.litigations = []
            r.targets = []
          end
        end
      end
    end
  end
end
