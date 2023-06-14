module CSVImport
  class CompanyCPBenchmarks < CPBenchmarks
    include Helpers

    private

    def source_klass
      Company
    end
  end
end
