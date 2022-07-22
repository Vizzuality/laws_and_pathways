class AddBanksTPISector < ActiveRecord::Migration[6.0]
  TPISector = Class.new(ActiveRecord::Base)

  def up
    TPISector.create_with(name: 'Banks', show_in_tpi_tool: false).find_or_create_by!(slug: 'banks')
  end

  def down
    TPISector.find_by(slug: 'banks')&.destroy!
  end
end
