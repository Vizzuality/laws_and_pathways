class ApplicationController < ActionController::Base
  before_action :set_current_user

  private

  def set_current_user
    Current.admin_user = current_admin_user
  end
end
