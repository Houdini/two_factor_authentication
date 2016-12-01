module ActionDispatch::Routing
  class Mapper
    protected

      def devise_two_factor_authentication(mapping, controllers)
        resource :two_factor_authentication, except: [:index, :destroy], path: mapping.path_names[:two_factor_authentication], controller: controllers[:two_factor_authentication] do
          collection do
            put 'verify'
            get 'resend_code'
          end
        end
      end
  end
end
