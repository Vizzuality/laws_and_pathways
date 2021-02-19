module CSVImport
  module Helpers
    module CachedCollections
      def geographies
        @geographies ||= Hash.new do |hash, iso|
          hash[iso] = Geography.find_by(iso: iso)
        end
      end

      def geographies_names
        @geographies_names ||= Hash.new do |hash, name|
          hash[name] = Geography.find_by(name: name)
        end
      end

      def keywords
        @keywords ||= Hash.new do |hash, keyword|
          hash[keyword.titleize] = Keyword.find_or_initialize_by(name: keyword.titleize)
        end
      end

      def frameworks
        @frameworks ||= Hash.new do |hash, keyword|
          hash[keyword.titleize] = Framework.find_or_initialize_by(name: keyword.titleize)
        end
      end

      def scopes
        @scopes ||= Hash.new do |hash, keyword|
          hash[keyword.titleize] = Scope.find_or_initialize_by(name: keyword.titleize)
        end
      end

      def document_types
        @document_types ||= Hash.new do |hash, keyword|
          hash[keyword.titleize] = DocumentType.find_or_initialize_by(name: keyword.titleize)
        end
      end

      def natural_hazards
        @natural_hazards ||= Hash.new do |hash, keyword|
          hash[keyword.titleize] = NaturalHazard.find_or_initialize_by(name: keyword.titleize)
        end
      end

      def political_groups
        @political_groups ||= Hash.new do |hash, keyword|
          hash[keyword] = PoliticalGroup.find_or_initialize_by(name: keyword)
        end
      end

      def responses
        @responses ||= Hash.new do |hash, keyword|
          hash[keyword.titleize] = Response.find_or_initialize_by(name: keyword.titleize)
        end
      end
    end
  end
end
