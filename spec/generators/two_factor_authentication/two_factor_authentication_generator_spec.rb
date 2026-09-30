require 'spec_helper'

require 'generators/two_factor_authentication/two_factor_authentication_generator'

describe TwoFactorAuthenticatable::Generators::TwoFactorAuthenticationGenerator, type: :generator do
  destination File.expand_path('../../../tmp/generators', __dir__)

  let(:model_path) { File.join(destination_root, 'app/models/account.rb') }

  before do
    prepare_destination
    FileUtils.mkdir_p(File.dirname(model_path))
    File.write(model_path, <<~RUBY)
      class Account < ApplicationRecord
        devise :database_authenticatable, :validatable
      end
    RUBY
  end

  it 'adds :two_factor_authenticatable to the devise call in the model' do
    run_generator %w(account --orm=active_record)

    expect(File.read(model_path)).to include('devise :two_factor_authenticatable, :database_authenticatable, :validatable')
  end

  it 'generates the migration through the orm hook' do
    run_generator %w(account --orm=active_record)

    expect(Pathname.new(migration_file('db/migrate/two_factor_authentication_add_to_accounts.rb'))).to exist
  end

  it 'does not fail when the model file is missing' do
    File.delete(model_path)

    expect { run_generator %w(account --orm=active_record) }.not_to raise_error
  end
end
