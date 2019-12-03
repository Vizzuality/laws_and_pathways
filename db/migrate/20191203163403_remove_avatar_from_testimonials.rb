class RemoveAvatarFromTestimonials < ActiveRecord::Migration[6.0]
  def change
    remove_column :testimonials, :avatar, :bigint
  end
end
