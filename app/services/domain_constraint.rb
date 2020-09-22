class DomainConstraint
  def initialize(domains)
    @domains = domains
  end

  def matches?(request)
    @domains.include? request.host
  end
end
