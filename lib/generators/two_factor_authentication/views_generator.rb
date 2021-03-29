require 'generators/devise/views_generator'

module TwoFactorAuthenticatable
  module Generators
    class ViewsGenerator < Rails::Generators::Base
      namespace 'two_factor_authentication:views'

      desc 'Copies all Devise Two Factor Authenticatable views to your application.'

      argument :scope, :required => false, :default => nil,
                       :desc => "The scope to copy views to"

      include ::Devise::Generators::ViewPathTemplates
      source_root File.expand_path("../../../../app/views/devise", __FILE__)
      def copy_views
        view_directory :two_factor_authentication
      end
    end
  end
end
