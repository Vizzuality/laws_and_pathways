class DomainConstraint
  def initialize(domains)
    @domains = domains
  end

  def matches?(request)
    host = request.host.start_with?('www.') ? request.host[4..] : request.host
    @domains.include? host
  end
end
