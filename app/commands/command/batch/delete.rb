module Command
  module Batch
    class Delete
      def initialize(collection, ids)
        @collection = collection
        @ids = ids
      end

      def call
        records_to_delete = @collection.where(id: [*@ids])

        return false if records_to_delete.empty?

        records_to_delete.all? do |resource|
          resource_command_klass(resource).new(resource).call
        end
      end

      def resource_command_klass(resource)
        "::Command::Destroy::#{resource.class.name}".constantize
      end
    end
  end
end
