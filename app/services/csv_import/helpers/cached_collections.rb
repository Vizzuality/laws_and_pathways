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
        @keywords ||= new_hash(Keyword, :titleize)
      end

      def frameworks
        @frameworks ||= new_hash(Framework, :titleize)
      end

      def scopes
        @scopes ||= new_hash(Scope, :titleize)
      end

      def document_types
        @document_types ||= new_hash(DocumentType, :titleize)
      end

      def natural_hazards
        @natural_hazards ||= new_hash(NaturalHazard, :titleize)
      end

      def political_groups
        @political_groups ||= new_hash(PoliticalGroup)
      end

      def responses
        @responses ||= new_hash(Response, :titleize)
      end

      def new_hash(klass, format_name = :to_s)
        Hash.new do |hash, keyword|
          key = keyword.strip.downcase
          hash[key] = find_by_name(klass, keyword.send(format_name)) unless hash.key?(key)
          hash[key]
        end
      end

      def find_by_name(klass, name)
        return klass.find_or_initialize_by(name: name) if allow_tags_adding

        entity = klass.where('lower(name) = ?', name.strip.downcase).first
        raise "Couldn't find #{klass.name} with name (case insensitive): '#{name}'" unless entity.present?

        entity
      end
    end
  end
end
