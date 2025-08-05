module ActionDispatch::Routing
  class Mapper
    protected

    def devise_two_factor_authentication(mapping, controllers)
      path = mapping.path_names[:two_factor_authentication]
      controller = controllers[:two_factor_authentication]

      resource :two_factor_authentication,
               only: [:show, :update],
               path: path,
               controller: controller

      post "#{path}/resend_code", to: "#{controller}#resend_code"
    end
  end
end
