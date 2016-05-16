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

    def direct_otp
      apply_devise_schema :direct_otp, String
    end

    def direct_otp_sent_at
      apply_devise_schema :direct_otp_sent_at, DateTime
    end

    def totp_timestamp
      apply_devise_schema :totp_timestamp, Timestamp
    end

    def backup_codes
      apply_devise_schema :backup_codes, String
    end
  end
end
