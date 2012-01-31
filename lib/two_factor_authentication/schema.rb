module TwoFactorAuthentication
  module Schema
    def two_factor_authenticatable
      apply_devise_schema :second_factor_pass_code, String, :limit => 32
      apply_devise_schema :second_factor_attempts_count, Integer, :default => 0
    end
  end
end
