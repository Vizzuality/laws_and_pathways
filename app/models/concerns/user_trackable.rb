module UserTrackable
  extend ActiveSupport::Concern

  included do
    before_create :set_created_by
    before_save   :set_updated_by

    belongs_to :created_by, class_name: 'AdminUser', foreign_key: 'created_by_id'
    belongs_to :updated_by, class_name: 'AdminUser', foreign_key: 'updated_by_id'

    scope :created_by, ->(user) { where(created_by_id: user.id) }
    scope :updated_by, ->(user) { where(updated_by_id: user.id) }
  end

  protected

  def set_created_by
    self.created_by = AdminUser.current_admin_user
    true
  end

  def set_updated_by
    self.updated_by = AdminUser.current_admin_user
    true
  end

end
