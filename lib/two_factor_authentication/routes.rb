module ActionDispatch::Routing
  class Mapper
    protected

      def devise_two_factor_authentication(mapping, controllers)
        # :resend_code is not a canonical resource action - it's added below
        # via the `collection` block. Rails < 8 tolerated the extra entry in
        # `only:`; Rails 8 validates it strictly and raises ArgumentError.
        resource :two_factor_authentication, :only => [:show, :update], :path => mapping.path_names[:two_factor_authentication], :controller => controllers[:two_factor_authentication] do
          collection { get "resend_code" }
        end
      end
  end
end
