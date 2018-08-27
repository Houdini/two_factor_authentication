require "active_record"

module TwoFactorAuthentication
  module Orm
    module ActiveRecord
      module Schema
        include TwoFactorAuthentication::Schema
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::Table.send :include, TwoFactorAuthentication::Orm::ActiveRecord::Schema
ActiveRecord::ConnectionAdapters::TableDefinition.send :include, TwoFactorAuthentication::Orm::ActiveRecord::Schema
