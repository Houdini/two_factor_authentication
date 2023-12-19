module TwoFactorAuthenticatable
  module Generators
    class TwoFactorAuthenticationGenerator < Rails::Generators::NamedBase
      namespace "two_factor_authentication"

      desc "Adds :two_factor_authenticable directive in the given model. It also generates an active record migration."

      def inject_two_factor_authentication_content
        path = File.join("app", "models", "#{file_path}.rb")
        inject_into_file(path, "two_factor_authenticatable, :", :after => "devise :") if File.exist?(path)
      end

      hook_for :orm

    end
  end
end
