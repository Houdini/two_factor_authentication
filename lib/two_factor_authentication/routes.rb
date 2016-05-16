module ActionDispatch::Routing
  class Mapper
    protected

      def devise_two_factor_authentication(mapping, controllers)
        resource :two_factor_authentication, :only => [:show, :update, :resend_code], :path => mapping.path_names[:two_factor_authentication], :controller => controllers[:two_factor_authentication] do
          collection do
            get "use_totp_code"
            get "use_backup_code"
            get "resend_code"
          end
        end
      end
  end
end
