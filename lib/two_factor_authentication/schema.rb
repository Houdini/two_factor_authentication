module TwoFactorAuthentication
  module Schema
    def second_factor_attempts_count
      apply_devise_schema :second_factor_attempts_count, Integer, :default => 0
    end

    def encrypted_otp_secret_key
      apply_devise_schema :encrypted_otp_secret_key, String
    end

    def encrypted_otp_secret_key_iv
      apply_devise_schema :encrypted_otp_secret_key_iv, String
    end

    def encrypted_otp_secret_key_salt
      apply_devise_schema :encrypted_otp_secret_key_salt, String
    end
  end
end
