module TPI
  class CPPerformanceSectorDecorator < Draper::Decorator
    delegate_all

    def cluster
      model.cluster&.name
    end

    def link
      h.link_to model.name, h.tpi_sector_path(model.slug)
    end

    def to_h
      {
        name: name,
        cluster: cluster,
        link: link
      }
    end
  end
end
