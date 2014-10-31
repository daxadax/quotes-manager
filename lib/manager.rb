require "manager/version"
require 'users'
require 'quotes'

module Manager

  DOMAINS = %w[Users Quotes]

  def self.create_quote(args)
    quote = call_use_case("Quotes", :CreateQuote, args)

    if quote.uid
      p "time to call the user!"
    end
    quote
  end

  def self.method_missing(method, args = nil)
    use_case = method.to_s.split('_').each(&:capitalize!).join.to_sym
    domain = domain_for use_case

    return call_use_case(domain, use_case, args) if domain
    super
  end

  private

  def self.call_use_case(domain, use_case, args)
    use_case = eval("#{domain}::UseCases::#{use_case}.new(#{args})")
    use_case.call
  end

  def self.domain_for(use_case)
    DOMAINS.each do |domain|
      use_cases = eval "#{domain}::UseCases.constants"
      return domain if use_cases.include?(use_case)
    end
  end

end
