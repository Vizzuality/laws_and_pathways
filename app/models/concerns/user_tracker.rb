module UserTracker
  extend ActiveSupport::Concern

  included do
    def self.current_admin_user=(user)
      RequestStore.store[:ut_current_user] = user
    end

    def self.current_admin_user
      RequestStore.store[:ut_current_user]
    end
  end
end
