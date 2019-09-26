module MQ
  class Question
    include ActiveModel::Model

    attr_accessor :level, :question, :answer, :number

    def key
      "Q#{number}L#{level}"
    end

    def csv_column_name
      "#{key}|#{question}"
    end
  end
end
