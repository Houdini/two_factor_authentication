module AuthenticatedModelHelper
  def build_guest_user
    GuestUser.new
  end

  def create_user(type = 'encrypted', attributes = {})
    create_table_for_nonencrypted_user if type == 'not_encrypted'

    User.create!(valid_attributes(attributes))
  end

  def create_admin
    Admin.create!(valid_attributes.except(:nickname))
  end

  def valid_attributes(attributes={})
    {
      nickname: 'Marissa',
      email: generate_unique_email,
      password: 'password',
      password_confirmation: 'password'
    }.merge(attributes)
  end

  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "user#{@@email_count}@example.com"
  end

  def create_table_for_nonencrypted_user
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Schema.define(version: 1) do
        create_table 'users', force: :cascade do |t|
          t.string    'email', default: '', null: false
          t.string    'encrypted_password', default: '', null: false
          t.string    'reset_password_token'
          t.datetime  'reset_password_sent_at'
          t.datetime  'remember_created_at'
          t.integer   'sign_in_count', default: 0,  null: false
          t.datetime  'current_sign_in_at'
          t.datetime  'last_sign_in_at'
          t.string    'current_sign_in_ip'
          t.string    'last_sign_in_ip'
          t.datetime  'created_at', null: false
          t.datetime  'updated_at', null: false
          t.integer   'second_factor_attempts_count', default: 0
          t.string    'nickname', limit: 64
          t.string    'otp_secret_key'
          t.string    'direct_otp'
          t.datetime  'direct_otp_sent_at'
          t.timestamp 'totp_timestamp'
        end
      end
    end
  end
end

RSpec.configuration.send(:include, AuthenticatedModelHelper)
