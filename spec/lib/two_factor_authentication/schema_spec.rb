require 'spec_helper'

describe TwoFactorAuthentication::Schema do
  let(:connection) { ActiveRecord::Base.connection }

  after { connection.drop_table(:schema_helper_users, if_exists: true) }

  def columns
    connection.columns(:schema_helper_users).index_by(&:name)
  end

  it 'adds every column in create_table' do
    connection.create_table(:schema_helper_users) do |t|
      t.second_factor_attempts_count
      t.encrypted_otp_secret_key
      t.encrypted_otp_secret_key_iv
      t.encrypted_otp_secret_key_salt
      t.direct_otp
      t.direct_otp_sent_at
      t.totp_timestamp
    end

    expect(columns['second_factor_attempts_count'].type).to eq(:integer)
    expect(columns['second_factor_attempts_count'].default.to_i).to eq(0)
    %w(encrypted_otp_secret_key encrypted_otp_secret_key_iv encrypted_otp_secret_key_salt direct_otp).each do |name|
      expect(columns[name].type).to eq(:string)
    end
    expect(columns['direct_otp_sent_at'].type).to eq(:datetime)
    expect(columns['totp_timestamp'].type).to eq(:datetime)
  end

  it 'adds columns in change_table' do
    connection.create_table(:schema_helper_users)
    connection.change_table(:schema_helper_users) do |t|
      t.second_factor_attempts_count
      t.totp_timestamp
    end

    expect(columns.keys).to include('second_factor_attempts_count', 'totp_timestamp')
  end
end
