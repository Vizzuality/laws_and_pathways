module Command
  module Destroy
    class Litigation
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap do |r|
            r.discard

            r.litigation_sides.discard_all
            r.events.discard_all
            r.documents.discard_all

            r.legislations = []
            r.external_legislations = []

            # Validation is false because it's possible that some precedent
            # record (like geography) was removed earlier
            r.save(validate: false)
          end
        end
      end
    end
  end
end
