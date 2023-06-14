module CSVImport
  class BankCPBenchmarks < CPBenchmarks
    include Helpers

    private

    def source_klass
      Bank
    end
  end
end
