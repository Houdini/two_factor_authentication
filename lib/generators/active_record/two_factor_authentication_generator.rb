require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class TwoFactorAuthenticationGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_two_factor_authentication_migration
        migration_template "migration.rb", "db/migrate/two_factor_authentication_add_to_#{table_name}.rb"
      end

    end
  end
end
