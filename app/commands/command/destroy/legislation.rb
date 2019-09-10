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

            r.documents.delete_all
            r.events.delete_all

            r.litigations = []
            r.targets = []
            r.save!
          end
        end
      end
    end
  end
end
