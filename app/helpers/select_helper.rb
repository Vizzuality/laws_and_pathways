module SelectHelper
  def array_to_select_collection(array)
    return unless array.respond_to?(:map)

    array.map { |s| [s.humanize, s] }
  end
end
