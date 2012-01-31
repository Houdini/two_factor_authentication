module TwoFactorAuthentication
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include TwoFactorAuthentication::Controllers::Helpers
    end
  end
end
