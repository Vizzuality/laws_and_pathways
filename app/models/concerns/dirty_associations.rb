module DirtyAssociations
  attr_accessor :dirty_associations

  def mark_changed(_object)
    self.dirty_associations = true
  end

  alias dirty_associations? dirty_associations

  def changed?
    dirty_associations? || super
  end

  def reload
    self.dirty_associations = false
    super
  end
end
