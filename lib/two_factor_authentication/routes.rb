module ActionDispatch::Routing
  class Mapper
    protected

      def devise_two_factor_authentication(mapping, controllers)
        resource :two_factor_authentication, only: [:show, :new, :create, :update, :resend_code], path: mapping.path_names[:two_factor_authentication], controller: controllers[:two_factor_authentication] do
          collection do
            get 'resend_code'
            get 'skip'
          end
        end
      end
  end
end
