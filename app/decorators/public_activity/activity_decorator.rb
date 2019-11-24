class PublicActivity::ActivityDecorator < Draper::Decorator
  delegate_all

  TRACKABLE_DISPLAY_NAME_MAPPING = {
    'Litigation' => :title,
    'Legislation' => :title,
    'Company' => :name,
    'Geography' => :name
  }.freeze

  TRACKABLE_ACTION_KEYS_MAPPING = {
    'draft' => 'moved to "Draft" state',
    'pending' => 'moved to "Pending" state',
    'published' => 'moved to "Published" state',
    'archived' => 'archived'
  }.freeze

  def activity_details
    resource, action = model.key.split('.')

    "#{resource} was #{TRACKABLE_ACTION_KEYS_MAPPING[action] || action}"
  end

  def updated_at_display
    "#{h.time_ago_in_words(updated_at)} ago (#{updated_at})"
  end

  def trackable_link
    # link to record if exists
    return h.link_to trackable_display_name(trackable), h.polymorphic_url([:admin, trackable]) if trackable

    # if trackable record does not exist, it could have been discarded
    discarded_trackable = find_discarded_trackable
    return trackable_display_name(discarded_trackable) if discarded_trackable

    # fallback message
    '(no record found)'
  end

  def find_discarded_trackable
    trackable_type.constantize.all_discarded.find(trackable_id)
  end

  def trackable_display_name(trackable_object)
    display_method = TRACKABLE_DISPLAY_NAME_MAPPING[trackable_type] || :to_s

    trackable_object.send(display_method).truncate(50)
  end
end
