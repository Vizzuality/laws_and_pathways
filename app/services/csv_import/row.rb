module CSVImport
  MissingHeader = Class.new(StandardError)

  class Row < SimpleDelegator
    def [](*args)
      raise MissingHeader, "CSV missing header: #{args[0]}" unless header?(args[0])

      super
    end
  end
end
