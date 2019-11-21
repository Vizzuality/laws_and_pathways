class PublicActivity::ActivityDecorator < Draper::Decorator
  delegate_all

  TRACKABLE_DISPLAY_NAME_MAPPING = {
    'Litigation' => :title,
    'Legislation' => :title,
    'Company' => :name
  }.freeze

  TRACKABLE_ACTION_KEYS_MAPPING = {
    'draft' => 'moved to DRAFT state',
    'pending' => 'moved to PENDING state',
    'published' => 'moved to PUBLISHED state',
    'archived' => 'archived'
  }.freeze

  def activity_details
    resource, action = model.key.split('.')
    "#{resource} was #{TRACKABLE_ACTION_KEYS_MAPPING[action] || action}"
  end

  def updated_at_display
    "#{h.time_ago_in_words(updated_at)} ago"
  end

  def trackable_link
    return h.link_to trackable_display_name(trackable) if trackable

    discarded_trackable = find_discarded_trackable
    trackable_display_name(discarded_trackable) if discarded_trackable
  end

  def find_discarded_trackable
    trackable_type.constantize.all_discarded.find(trackable_id)
  end

  def trackable_display_name(trackable_object)
    trackable_object.send(TRACKABLE_DISPLAY_NAME_MAPPING[trackable_type] || :to_s).truncate(50)
  end
end
