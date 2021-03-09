class AddPositionToContent < ActiveRecord::Migration[6.0]
  def change
    add_column :contents, :position, :integer

    Page.all.each do |page|
      page.contents.order(:created_at).each.with_index(1) do |content, index|
        content.update!(position: index)
      end
    end
  end
end
