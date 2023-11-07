module MQAssessmentHelper
  def hide_mq_assessments_with_same_date(assessments)
    result = []
    assessments.group_by(&:assessment_date).each { |_date, a| result << a.max_by(&:methodology_version) }
    result
  end
end
