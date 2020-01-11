module SelectHelper
  def current_user?(user)
    current_admin_user.id == user.id
  end

  def current_user_is_editor?
    current_admin_user.role.to_s[/editor/]
  end

  def visibility_status_select_options
    if current_user_is_editor?
      {as: :select, input_html: {readonly: true, disabled: true}}
    else
      {as: :select}
    end
  end

  def allowed_user_roles_select_collection
    array_to_select_collection(allowed_user_roles_to_select, :titleize)
  end

  def array_to_select_collection(array, transform_func = :humanize)
    return unless array.respond_to?(:map)

    array.map do |s|
      return [s, s] unless s.respond_to?(transform_func)

      [s.send(transform_func), s]
    end
  end

  # Returns roles which current user can set when creating/editing other users
  # - super users can edit set any role to anyone
  # - publishers can create publishers/editors from their area (LAWS/TPI)
  #
  def allowed_user_roles_to_select
    case current_admin_user.role
    when 'super_user'
      AdminUser::ROLES
    when 'publisher_laws'
      %w[publisher_laws editor_laws]
    when 'publisher_tpi'
      %w[publisher_tpi editor_tpi]
    else
      []
    end
  end

  def all_languages_to_select_collection
    ::Language.common.map { |language| [language.name, language.iso_639_1] }
  end
end
