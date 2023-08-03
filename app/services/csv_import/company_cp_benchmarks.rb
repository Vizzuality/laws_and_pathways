module CSVImport
  class CompanyCPBenchmarks < CPBenchmarks
    include Helpers

    private

    def category_klass
      Company
    end
  end
end
