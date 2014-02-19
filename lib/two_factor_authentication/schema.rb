module TwoFactorAuthentication
  module Schema
    def otp_secret_key
      apply_devise_schema :otp_secret_key, String
    end

    def second_factor_attempts_count
      apply_devise_schema :second_factor_attempts_count, Integer, :default => 0
    end
  end
end
