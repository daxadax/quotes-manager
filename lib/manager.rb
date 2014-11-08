require "manager/version"
require 'users'
require 'quotes'

module Manager

  DOMAINS = [
    Users,
    Quotes
  ]

  def self.create_quote(args)
    quote = call_use_case(Quotes, :CreateQuote, args)

    publish_quote_for_user(args[:user_uid], quote.uid) unless quote.error
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

  def self.publish_quote_for_user(user_uid, quote_uid)
    input = {
      :uid => user_uid,
      :quote_uid => quote_uid
    }

    call_use_case(Users, :PublishQuote, input)
  end

  def self.domain_for(use_case)
    DOMAINS.each do |domain|
      use_cases = eval "#{domain}::UseCases.constants"
      return domain if use_cases.include?(use_case)
    end
    raise ArgumentError, "You tried to call '#{use_case}', but it doesn't exist\n"
  end

end
