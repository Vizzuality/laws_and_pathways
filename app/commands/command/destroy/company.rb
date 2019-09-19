module Command
  module Destroy
    class Company
      def initialize(resource)
        @resource = resource
      end

      def call
        ActiveRecord::Base.transaction do
          @resource.tap do |r|
            r.discard
            r.litigation_sides.discard_all
            r.mq_assessments.discard_all
            r.cp_assessments.discard_all

            r.litigations = []
          end
        end
      end
    end
  end
end
