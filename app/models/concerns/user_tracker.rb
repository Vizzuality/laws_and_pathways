module UserTracker
  extend ActiveSupport::Concern

  included do
    def self.current_admin_user=(user)
      Current.admin_user = user
    end

    def self.current_admin_user
      Current.admin_user
    end
  end
end
