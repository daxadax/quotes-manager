module Manager
  module Interface

    DOMAINS = %i[
      Users
      Quotes
    ]

    def self.create_quote(args)
      result = call_use_case Quotes, :CreateQuote, args

      update_added(args[:user_uid], :quote, result.uid) unless result.error
      result
    end

    def self.delete_quote(args)
      result = call_use_case Quotes, :DeleteQuote, args

      update_added(args[:user_uid], :quote, args[:uid]) unless result.error
      result
    end

    def self.create_publication(args)
      result = call_use_case Quotes, :CreatePublication, args

      update_added(args[:user_uid], :publication, result.uid) unless result.error
      result
    end

    def self.delete_publication(args)
      result = call_use_case Quotes, :DeletePublication, args

      update_added(args[:user_uid], :publication, args[:uid]) unless result.error
      result
    end

    def self.authenticate_user(args)
      result = call_use_case Users, :AuthenticateUser, args

      unless result.error
        call_use_case Users, :UpdateUser,
          :uid => result.uid,
          :auth_key => args[:auth_key],
          :updates => {
            :last_login_address => args[:login_data][:ip_address],
            :last_login_time => Time.now.utc.to_i,
            :update_login_count => true
          }
      end
      result
    end

    def self.method_missing(method, args = nil)
      use_case = method.to_s.split('_').each(&:capitalize!).join.to_sym
      domain = domain_for use_case

      return call_use_case(domain, use_case, args) if domain
      raise ArgumentError "You tried to call #{method}, but it doesn't exist"
    end

    private

    def self.call_use_case(domain, use_case, args)
      use_case = eval("#{domain}::UseCases::#{use_case}.new(#{args})")
      use_case.call
    end

    def self.update_added(user_uid, type, object_uid)
      args = { :uid => user_uid }
      args[:quote_uid] = object_uid if type == :quote
      args[:publication_uid] = object_uid if type == :publication

      call_use_case Users, :UpdateAdded, args
    end

    def self.domain_for(use_case)
      DOMAINS.each do |domain|
        use_cases = eval "#{domain}::UseCases.constants"
        return domain if use_cases.include?(use_case)
      end
      raise ArgumentError, "You tried to call '#{use_case}', but it doesn't exist\n"
    end

  end
end
