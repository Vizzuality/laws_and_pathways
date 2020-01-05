module SelectHelper
  def array_to_select_collection(array, transform_func = :humanize)
    return unless array.respond_to?(:map)

    array.map do |s|
      return [s, s] unless s.respond_to?(transform_func)

      [s.send(transform_func), s]
    end
  end

  def user_roles_select_collection
    array_to_select_collection(current_user_roles_to_select, :titleize)
  end

  # returns roles which current user can set when creating/editing other users
  def current_user_roles_to_select
    case current_admin_user.role
    when 'super_user'
      AdminUser::ROLES
    when 'publisher_laws'
      %w[publisher_laws editor_laws]
    when 'publisher_tpi'
      %w[publisher_tpi editor_tpi]
    end
  end

  def all_languages_to_select_collection
    ::Language.common.map { |language| [language.name, language.iso_639_1] }
  end
end
