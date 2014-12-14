require 'manager/version'
require 'manager/interface'
require 'users'
require 'quotes'

module Manager
  include Interface

  Quotes::ServiceFactory.register :quotes_backend do
    Persistence::Gateways::QuotesGatewayBackend.new
  end

  Quotes::ServiceFactory.register :publications_backend do
    Persistence::Gateways::PublicationsGatewayBackend.new
  end

  Users::ServiceFactory.register :users_backend do
    Persistence::Gateways::UsersGatewayBackend.new
  end

end
