class TestimonialDecorator < Draper::Decorator
  delegate_all

  def author_link
    h.link_to model.author, h.admin_testimonial_path(model)
  end
end
