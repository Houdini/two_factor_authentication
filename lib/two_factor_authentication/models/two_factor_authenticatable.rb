require 'two_factor_authentication/hooks/two_factor_authenticatable'
module Devise
  module Models
    module TwoFactorAuthenticatable
      extend ActiveSupport::Concern

      module ClassMethods
        ::Devise::Models.config(self, :login_code_random_pattern, :max_login_attempts)
      end

      def need_two_factor_authentication?
        true
      end

      def generate_two_factor_code
        self.class.login_code_random_pattern.gen
      end

      def send_two_factor_authentication_code(code)
        p "Code is #{code}"
      end

      def max_login_attempts?
        second_factor_attempts_count >= self.class.max_login_attempts
      end
    end
  end
end
