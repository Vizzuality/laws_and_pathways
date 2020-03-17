module CapybaraHelpers
  def contains_class(class_name)
    "contains(concat(' ', normalize-space(@class), ' '), ' #{class_name} ')"
  end
end
