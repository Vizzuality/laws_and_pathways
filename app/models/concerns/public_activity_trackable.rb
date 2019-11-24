# Tracks updates of:
# - common attributes updates (visibility_status, discarded_at)
# - deletes
#
# Required to be implemmented by the model
# - create_activity (from PublicActivity::Common)
#
module PublicActivityTrackable
  extend ActiveSupport::Concern

  included do
    include PublicActivity::Common

    around_update :track_updates_activity
  end

  protected

  def track_updates_activity
    yield

    return unless errors.blank? && previous_changes.present?

    create_activity activity_key_for_last_update, owner: owner
  end

  def owner
    ::Current.admin_user
  end

  def activity_key_for_last_update
    if previous_changes['visibility_status']
      previous_changes['visibility_status'].last
    elsif previous_changes['discarded_at']
      'deleted'
    else
      'edited'
    end
  end
end
