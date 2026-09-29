require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class TwoFactorAuthenticationGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_two_factor_authentication_migration
        migration_template "migration.rb", "db/migrate/two_factor_authentication_add_to_#{table_name}.rb"
      end

      private

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
      end

      # CREATE INDEX CONCURRENTLY is PostgreSQL-only; other adapters reject the option.
      def postgresql?
        config = if ActiveRecord::Base.respond_to?(:connection_db_config)
                   ActiveRecord::Base.connection_db_config
                 else
                   ActiveRecord::Base.connection_config
                 end
        adapter = config.respond_to?(:adapter) ? config.adapter : config[:adapter]
        adapter.to_s.include?("postg")
      rescue StandardError
        false
      end
    end
  end
end
