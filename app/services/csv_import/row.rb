module CSVImport
  MissingHeader = Class.new(StandardError)

  class Row < SimpleDelegator
    def [](*args)
      raise MissingHeader, "CSV missing header: #{args[0].to_s.humanize(keep_id_suffix: true)}" unless header?(args[0])

      super
    end
  end
end
