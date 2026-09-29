require 'spec_helper'

require 'generators/active_record/two_factor_authentication_generator'

describe ActiveRecord::Generators::TwoFactorAuthenticationGenerator, type: :generator do
  destination File.expand_path('../../../tmp/generators', __dir__)

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
      subject { Pathname.new(migration_file('db/migrate/two_factor_authentication_add_to_users.rb')) }

      it { is_expected.to exist }
      it { is_expected.to be_a_migration }
      it { is_expected.to contain /< ActiveRecord::Migration\[#{ActiveRecord::VERSION::MAJOR}\.#{ActiveRecord::VERSION::MINOR}\]/ }
      it { is_expected.to contain /def change/ }
      it { is_expected.to contain /add_column :users, :second_factor_attempts_count, :integer, default: 0/ }
      it { is_expected.to contain /add_column :users, :encrypted_otp_secret_key, :string/ }
      it { is_expected.to contain /add_column :users, :encrypted_otp_secret_key_iv, :string/ }
      it { is_expected.to contain /add_column :users, :encrypted_otp_secret_key_salt, :string/ }
      it { is_expected.to contain /add_column :users, :direct_otp, :string/ }
      it { is_expected.to contain /add_column :users, :direct_otp_sent_at, :datetime/ }
      it { is_expected.to contain /add_column :users, :totp_timestamp, :timestamp/ }
      it { is_expected.to contain /add_index :users, :encrypted_otp_secret_key, unique: true$/ }
      it { is_expected.not_to contain /concurrently/ }
      it { is_expected.not_to contain /disable_ddl_transaction!/ }
    end
  end

  describe 'on PostgreSQL' do
    subject { Pathname.new(migration_file('db/migrate/two_factor_authentication_add_to_users.rb')) }

    before do
      gen = generator %w(users)
      allow(gen).to receive(:postgresql?).and_return(true)
      gen.invoke_all
    end

    it { is_expected.to contain /disable_ddl_transaction!/ }
    it { is_expected.to contain /add_index :users, :encrypted_otp_secret_key, unique: true, algorithm: :concurrently/ }
  end

  describe 'running the generated migration' do
    let(:connection) { ActiveRecord::Base.connection }

    before do
      connection.create_table(:accounts) { |t| t.string :email }
      run_generator %w(accounts)
      load migration_file('db/migrate/two_factor_authentication_add_to_accounts.rb')
    end

    after do
      connection.drop_table(:accounts, if_exists: true)
      Object.send(:remove_const, :TwoFactorAuthenticationAddToAccounts)
    end

    it 'adds the two factor columns and index' do
      ActiveRecord::Migration.suppress_messages do
        TwoFactorAuthenticationAddToAccounts.migrate(:up)
      end

      expect(connection.columns(:accounts).map(&:name)).to include(
        'second_factor_attempts_count', 'encrypted_otp_secret_key',
        'encrypted_otp_secret_key_iv', 'encrypted_otp_secret_key_salt',
        'direct_otp', 'direct_otp_sent_at', 'totp_timestamp'
      )
      expect(connection.index_exists?(:accounts, :encrypted_otp_secret_key, unique: true)).to eq(true)
    end
  end
end
