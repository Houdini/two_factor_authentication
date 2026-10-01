module TwoFactorAuthentication
  module Schema
    def second_factor_attempts_count
      integer :second_factor_attempts_count, :default => 0
    end

    def encrypted_otp_secret_key
      string :encrypted_otp_secret_key
    end

    def encrypted_otp_secret_key_iv
      string :encrypted_otp_secret_key_iv
    end

    def encrypted_otp_secret_key_salt
      string :encrypted_otp_secret_key_salt
    end

    def direct_otp
      string :direct_otp
    end

    def direct_otp_sent_at
      datetime :direct_otp_sent_at
    end

    def totp_timestamp
      timestamp :totp_timestamp
    end
  end
end
