require 'manager/version'
require 'manager/interface'
require 'users'
require 'quotes'

module Manager
  include Interface

  DOMAINS = [
    Users,
    Quotes
  ]

  Quotes::ServiceFactory.register :quotes_backend do
    Persistence::Gateways::QuotesGatewayBackend.new
  end

  Quotes::ServiceFactory.register :publications_backend do
    Persistence::Gateways::PublicationsGatewayBackend.new
  end

end
