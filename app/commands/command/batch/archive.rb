module Command
  module Batch
    class Archive
      def initialize(collection, ids)
        @collection = collection
        @ids = ids
      end

      def call
        @collection
          .where(id: [*@ids])
          .update_all(visibility_status: 'archived')
      end
    end
  end
end
