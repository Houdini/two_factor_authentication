module TwoFactorAuthentication
  module Schema
    def second_factor_pass_code
      apply_devise_schema :second_factor_pass_code, String, :limit => 32
    end

    def second_factor_attempts_count
      apply_devise_schema :second_factor_attempts_count, Integer, :default => 0
    end
  end
end
