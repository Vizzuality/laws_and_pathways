module SelectHelper
  def array_to_select_collection(array, transform_func = :humanize)
    return unless array.respond_to?(:map)

    array.map do |s|
      return [s, s] unless s.respond_to?(transform_func)

      [s.send(transform_func), s]
    end
  end

  def all_languages_to_select_collection
    ::Language.common.map { |language| [language.name, language.iso_639_1] }
  end
end
