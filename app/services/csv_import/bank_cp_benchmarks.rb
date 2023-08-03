module CSVImport
  class BankCPBenchmarks < CPBenchmarks
    include Helpers

    private

    def category_klass
      Bank
    end
  end
end
