require 'spec_helper'

require 'generators/active_record/two_factor_authentication_generator'

describe ActiveRecord::Generators::TwoFactorAuthenticationGenerator, type: :generator do
  destination File.expand_path('../../../../../tmp', __FILE__)

  before do
    prepare_destination
  end

  it 'runs all methods in the generator' do
    gen = generator %w(users)
    expect(gen).to receive(:copy_two_factor_authentication_migration)
    gen.invoke_all
  end

  describe 'the generated files' do
    before do
      run_generator %w(users)
    end

    describe 'the migration' do
      subject { migration_file('db/migrate/two_factor_authentication_add_to_users.rb') }

      it { is_expected.to exist }
      it { is_expected.to be_a_migration }
      it { is_expected.to contain /def change/ }
      it { is_expected.to contain /add_column :users, :otp_enabled, :boolean, default: false/ }
      it { is_expected.to contain /add_column :users, :second_factor_attempts_count, :integer, default: 0/ }
      it { is_expected.to contain /add_column :users, :encrypted_otp_secret_key, :string/ }
      it { is_expected.to contain /add_column :users, :encrypted_otp_secret_key_iv, :string/ }
      it { is_expected.to contain /add_column :users, :encrypted_otp_secret_key_salt, :string/ }
      it { is_expected.to contain /add_index :users, :encrypted_otp_secret_key, unique: true/ }
    end
  end
end
