module Command
  module Batch
    class Publish
      def initialize(collection, ids)
        @collection = collection
        @ids = ids
      end

      def call
        @collection
          .where(id: [*@ids])
          .update(visibility_status: 'published')
      end
    end
  end
end
