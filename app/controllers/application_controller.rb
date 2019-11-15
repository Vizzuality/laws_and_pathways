class ApplicationController < ActionController::Base
  include BaseAuth

  before_action :set_current_user
  before_action :set_paper_trail_whodunnit

  around_action :use_logidze_responsible, only: %i[create update]

  def use_logidze_responsible(&block)
    Logidze.with_responsible(get_current_user.email, &block)
  end

  private

  def set_current_user
    ::Current.admin_user = current_admin_user
  end

  def get_current_user
    ::Current.admin_user
  end

  def user_for_paper_trail
    get_current_user
  end
end
