class FixMQAssessmentQuestionTexts < ActiveRecord::Migration[6.1]
  def up
    # Version 1.0: Q4L2 (index 3)
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{3,question}', '"Has the company set energy efficiency or relative or absolute greenhouse gas emission reduction targets?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 1
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 3;
    SQL

    # Version 1.0: Q7L3 (index 6)
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{6,question}', '"Has the company set quantitative relative or absolute targets for reducing its operational (Scope 1 and 2) greenhouse gas emissions?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 1
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 6;
    SQL

    # Version 1.0: Q11L4 (index 10)
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{10,question}', '"Has the company reduced its operational (Scope 1 and 2) greenhouse gas emissions over the past 3 years?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 1
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 10;
    SQL

    # Version 1.0: Q12L4 (index 11)
    # Note: en dash (\u2013) used between clauses
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{11,question}', '"Does the company provide information on the business costs \\u2013 for example, capital investments, costs of carbon permits \\u2013 associated with climate change?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 1
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 11;
    SQL

    # Version 1.0: Q13L4 (index 12)
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{12,question}', '"Has the company set long-term relative or absolute targets for reducing its greenhouse gas emission?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 1
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 12;
    SQL

    # Version 1.0: Q14L4 (index 13)
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{13,question}', '"Has the company incorporated environmental, social and governance issues into executive remuneration?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 1
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 13;
    SQL

    # Version 2.0: Q12L3 (index 11)
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{11,question}', '"Does the company disclose materially important Scope 3 emissions?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 2
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 11;
    SQL

    # Version 3.0: Q13L3 (index 12)
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{12,question}', '"Does the company disclose materially important Scope 3 emissions?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 3
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 12;
    SQL

    # Version 4.0: Q12L3 (index 11)
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{11,question}', '"Does the company disclose materially important Scope 3 emissions?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 4
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 11;
    SQL

    # Version 5.0: Q18L4 (index 17)
    execute <<~SQL
      UPDATE mq_assessments
      SET questions = jsonb_set(questions, '{17,question}', '"Does the company disclose the actions necessary to meet its emissions reduction targets?"'::jsonb),
          updated_at = NOW()
      WHERE methodology_version = 5
        AND questions IS NOT NULL
        AND jsonb_array_length(questions) > 17;
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
