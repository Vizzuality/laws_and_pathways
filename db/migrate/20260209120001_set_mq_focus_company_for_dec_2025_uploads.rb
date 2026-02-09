class SetMqFocusCompanyForDec2025Uploads < ActiveRecord::Migration[6.1]
  def up
    company_ids = MQ::Assessment
      .where(created_at: Date.new(2025, 12, 1)..Date.new(2025, 12, 31).end_of_day)
      .select(:company_id)
      .distinct

    Company.where(id: company_ids).update_all(mq_focus_company: true)
  end

  def down
    Company.where(mq_focus_company: true).update_all(mq_focus_company: false)
  end
end

