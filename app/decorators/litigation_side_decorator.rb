class LitigationSideDecorator < Draper::Decorator
  delegate_all

  def party_type
    model.party_type&.humanize
  end

  def side_type
    model.side_type&.humanize
  end
end
