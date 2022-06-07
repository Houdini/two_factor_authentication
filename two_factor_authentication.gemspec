# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "two_factor_authentication/version"

Gem::Specification.new do |s|
  s.name        = "two_factor_authentication"
  s.version     = TwoFactorAuthentication::VERSION.dup
  s.authors     = ["Dmitrii Golub"]
  s.email       = ["dmitrii.golub@gmail.com"]
  s.homepage    = "https://github.com/Houdini/two_factor_authentication"
  s.summary     = %q{Two factor authentication plugin for devise}
  s.license     = "MIT"
  s.description = <<-EOF
    ### Features ###
    * control sms code pattern
    * configure max login attempts
    * per user level control if he really need two factor authentication
    * your own sms logic
  EOF

  s.rubyforge_project = "two_factor_authentication"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'rails', '>= 3.1.1'
  s.add_runtime_dependency 'devise'
  s.add_runtime_dependency 'randexp'
  s.add_runtime_dependency 'rotp', '>= 4.0.0'
  s.add_runtime_dependency 'encryptor'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec-rails', '>= 3.0.1'
  s.add_development_dependency 'capybara', '~> 2.5'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'timecop'
end
