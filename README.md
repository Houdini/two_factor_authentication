# Two factor authentication for Devise

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Houdini/two_factor_authentication?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![CI](https://github.com/Houdini/two_factor_authentication/actions/workflows/ci.yml/badge.svg)](https://github.com/Houdini/two_factor_authentication/actions/workflows/ci.yml)
[![Code Climate](https://codeclimate.com/github/Houdini/two_factor_authentication.svg)](https://codeclimate.com/github/Houdini/two_factor_authentication)

## Features

* Support for 2 types of OTP codes
    1. Codes delivered directly to the user
    2. TOTP (Google Authenticator) codes based on a shared secret (HMAC)
* Configurable OTP code digit length
* Configurable max login attempts
* Customizable logic to determine if a user needs two factor authentication
* Configurable period where users won't be asked for 2FA again
* Option to encrypt the TOTP secret in the database, with iv and salt

## Configuration

### Initial Setup

In a Rails environment, require the gem in your Gemfile:

    gem 'two_factor_authentication'

Once that's done, run:

    bundle install

The gem is tested on Ruby 3.2 – 4.0 with Rails 7.2, 8.0 and 8.1 and Devise 5.

### Installation

#### Automatic initial setup

To set up the model and database migration file automatically, run the
following command:

    bundle exec rails g two_factor_authentication MODEL

Where MODEL is your model name (e.g. User or Admin). This generator will add
`:two_factor_authenticatable` to your model's Devise options and create a
migration in `db/migrate/`, which will add the following columns to your table:

- `:second_factor_attempts_count`
- `:encrypted_otp_secret_key`
- `:encrypted_otp_secret_key_iv`
- `:encrypted_otp_secret_key_salt`
- `:direct_otp`
- `:direct_otp_sent_at`
- `:totp_timestamp`

#### Manual initial setup

If you prefer to set up the model and migration manually, add the
`:two_factor_authenticatable` option to your existing devise options, such as:

```ruby
devise :database_authenticatable, :registerable, :recoverable, :rememberable,
       :trackable, :validatable, :two_factor_authenticatable
```

Then create your migration file using the Rails generator, such as:

```
rails g migration AddTwoFactorFieldsToUsers second_factor_attempts_count:integer encrypted_otp_secret_key:string:index encrypted_otp_secret_key_iv:string encrypted_otp_secret_key_salt:string direct_otp:string direct_otp_sent_at:datetime totp_timestamp:timestamp
```

Open your migration file (it will be in the `db/migrate` directory and will be
named something like `20151230163930_add_two_factor_fields_to_users.rb`), and
set the attempt counter's default to `0` and add `unique: true` to the
`add_index` line so that they look like this:

```ruby
add_column :users, :second_factor_attempts_count, :integer, default: 0
add_index :users, :encrypted_otp_secret_key, unique: true
```
Save the file.

The counter must contain an integer because failed OTP submissions increment
it. If you already ran a migration without this default, add a follow-up
migration that sets the default to `0` and backfills existing `NULL` counters
to `0`, preserving other counter values.

#### Complete the setup

Run the migration with:

    bundle exec rake db:migrate

Add the following line to your model to fully enable two-factor auth:

    has_one_time_password(encrypted: true)

Set config values in `config/initializers/devise.rb`:

```ruby
config.max_login_attempts = 3  # Maximum second factor attempts count.
config.allowed_otp_drift_seconds = 30  # Allowed TOTP time drift between client and server.
config.otp_length = 6  # TOTP code length
config.direct_otp_valid_for = 5.minutes  # Time before direct OTP becomes invalid
config.direct_otp_length = 6  # Direct OTP code length
config.remember_otp_session_for_seconds = 30.days  # Time before browser has to perform 2fA again. Default is 0.
config.otp_secret_encryption_key = ENV['OTP_SECRET_ENCRYPTION_KEY']
config.second_factor_resource_id = 'id' # Field or method name used to set value for 2fA remember cookie
config.delete_cookie_on_logout = false # Delete cookie when user signs out, to force 2fA again on login
```
The `otp_secret_encryption_key` must be a random key that is not stored in the
DB, and is not checked in to your repo. It is recommended to store it in an
environment variable, and you can generate it with `bundle exec rake secret`.

Override the method in your model in order to send direct OTP codes. This is
automatically called when a user logs in unless they have TOTP enabled (see
below):

```ruby
def send_two_factor_authentication_code(code)
  # Send code via SMS, etc.
end
```

### Customisation and Usage

By default, second factor authentication is required for each user. You can
change that by overriding the following method in your model:

```ruby
def need_two_factor_authentication?(request)
  request.ip != '127.0.0.1'
end
```

In the example above, two factor authentication will not be required for local
users.

This gem is compatible with [Google Authenticator](https://support.google.com/accounts/answer/1066447?hl=en).
To enable this a shared secret must be generated by invoking the following
method on your model:

```ruby
user.generate_totp_secret
```

This must then be shared via a provisioning uri:

```ruby
user.provisioning_uri # This assumes a user model with an email attribute
```

This provisioning uri can then be turned in to a QR code if desired so that
users may add the app to Google Authenticator easily.  Once this is done, they
may retrieve a one-time password directly from the Google Authenticator app.

#### Overriding the view

The default view that shows the form can be overridden by adding a
file named `show.html.erb` (or `show.html.haml` if you prefer HAML)
inside `app/views/devise/two_factor_authentication/` and customizing it.
Below is an example using ERB:


```html
<h2>Hi, you received a code by email, please enter it below, thanks!</h2>

<%= form_tag([resource_name, :two_factor_authentication], :method => :put) do %>
  <%= text_field_tag :code %>
  <%= submit_tag "Log in!" %>
<% end %>

<%= button_to "Sign out", destroy_user_session_path, :method => :delete %>
```

#### Upgrading from version 1.X to 2.X

The following database fields are new in version 2.

- `direct_otp`
- `direct_otp_sent_at`
- `totp_timestamp`

To add them, generate a migration such as:

    $ rails g migration AddTwoFactorFieldsToUsers direct_otp:string direct_otp_sent_at:datetime totp_timestamp:timestamp

The `otp_secret_key` is only required for users who use TOTP (Google Authenticator) codes,
so unless it has been shared with the user it should be set to `nil`.  The
following pseudo-code is an example of how this might be done:

```ruby
User.find_each do |user| do
  if !uses_authenticator_app(user)
    user.otp_secret_key = nil
    user.save!
  end
end
```

#### Adding the TOTP encryption option to an existing app

If you've already been using this gem, and want to start encrypting the OTP
secret key in the database (recommended), you'll need to perform the following
steps:

1. Generate a migration to add the necessary columns to your model's table:

   ```
   rails g migration AddEncryptionFieldsToUsers encrypted_otp_secret_key:string:index encrypted_otp_secret_key_iv:string encrypted_otp_secret_key_salt:string
   ```

   Open your migration file (it will be in the `db/migrate` directory and will be
   named something like `20151230163930_add_encryption_fields_to_users.rb`), and
   add `unique: true` to the `add_index` line so that it looks like this:

   ```ruby
   add_index :users, :encrypted_otp_secret_key, unique: true
   ```
   Save the file.

2. Run the migration: `bundle exec rake db:migrate`

2. Update the gem: `bundle update two_factor_authentication`

3. Add `encrypted: true` to `has_one_time_password` in your model.
   For example: `has_one_time_password(encrypted: true)`

4. Generate a migration to populate the new encryption fields:
   ```
   rails g migration PopulateEncryptedOtpFields
   ```

   Open the generated file, and replace its contents with the following:
   ```ruby
   class PopulateEncryptedOtpFields < ActiveRecord::Migration[8.1]
     def up
       User.reset_column_information

       User.find_each do |user|
         user.otp_secret_key = user.read_attribute('otp_secret_key')
         user.save!
       end
     end

     def down
       User.reset_column_information

       User.find_each do |user|
         # Read through the encrypted accessor, then write the plaintext column
         # directly without invoking the encrypted setter.
         user.update_columns(otp_secret_key: user.otp_secret_key)
       end
     end
   end
   ```

5. Generate a migration to remove the `:otp_secret_key` column:
   ```
   rails g migration RemoveOtpSecretKeyFromUsers otp_secret_key:string
   ```

6. Run the migrations: `bundle exec rake db:migrate`

If, for some reason, you want to switch back to the old non-encrypted version,
use these steps:

1. Stop application writes while rolling back and changing the model
   configuration. Keep `has_one_time_password(encrypted: true)` and the same
   `otp_secret_encryption_key` configured throughout the rollback.

2. Roll back the last 3 migrations (assuming you haven't added any new ones
   after them):
   ```
   bundle exec rake db:rollback STEP=3
   ```

   This recreates the plaintext column, copies each decrypted secret back into
   it, and then removes the encryption columns. Existing authenticator secrets
   are preserved, and users without TOTP retain a `nil` secret.

3. Remove `(encrypted: true)` from `has_one_time_password` and restart the
   application before allowing writes again.

#### Critical Security Note! Add before_action to your user registration controllers

You should have a file registrations_controller.rb in your controllers folder
to overwrite/customize user registrations. It should include the lines below, for 2FA protection of user model updates, meaning that users can only access the users/edit page after confirming 2FA fully, not simply by logging in. Otherwise the entire 2FA system can be bypassed!

   ```ruby
   class RegistrationsController < Devise::RegistrationsController
     before_action :confirm_two_factor_authenticated, except: [:new, :create, :cancel]
   
     protected
   
     def confirm_two_factor_authenticated
       return if is_fully_authenticated?

       flash[:error] = t('devise.errors.messages.user_not_authenticated')
       redirect_to user_two_factor_authentication_url
     end
   end
   ```

   Route registrations through this controller in `config/routes.rb`:

   ```ruby
   devise_for :users, controllers: { registrations: 'registrations' }
   ```

   Update your existing `devise_for :users` declaration. Defining the controller
   alone does not change Devise's routes, so the callback will not run until
   this mapping is configured.

   `is_fully_authenticated?` checks the scope of the current Devise controller,
   or `Devise.default_scope` elsewhere. Pass a scope to check another model,
   e.g. `is_fully_authenticated?(:admin)`.

#### Critical Security Note! Add 2FA validation to your custom user actions

Require fresh second-factor verification for sensitive account changes,
including replacing or disabling TOTP. Verify a code against the existing
secret before assigning a replacement; a code for the replacement secret only
proves that the user configured the new authenticator.

For initial TOTP enrollment, verify a fresh direct OTP instead. The following
example generates a pending secret on the server, keeps it separate from the
active secret, and requires separate `current_code` and `new_code` values:

```ruby
class AccountController < ApplicationController
  before_action :authenticate_user!

  def new_totp
    secret = current_user.generate_totp_secret
    session[:pending_totp] = { 'user_id' => current_user.id, 'secret' => secret }
    current_user.send_new_otp unless current_user.totp_enabled?
    render json: { provisioning_uri: current_user.provisioning_uri(nil, otp_secret_key: secret) }
  end

  def update_totp
    codes = params.require(:two_factor).permit(:current_code, :new_code)
    pending = session[:pending_totp]
    unless pending && pending['user_id'] == current_user.id
      render json: { error: 'Start TOTP setup first.' }, status: :unprocessable_entity
      return
    end

    updated = false
    current_user.with_lock do
      next if current_user.max_login_attempts?

      valid_current_code = if current_user.totp_enabled?
                             current_user.authenticate_totp(codes[:current_code].to_s)
                           else
                             current_user.authenticate_direct_otp(codes[:current_code].to_s)
                           end
      unless valid_current_code
        current_user.increment!(:second_factor_attempts_count)
        next
      end

      # Persist consumption of the current code even if the new code is invalid.
      current_user.save!

      # The new secret has its own replay timestamp, independent of the old one.
      candidate = current_user.class.new
      next unless candidate.confirm_totp_secret(pending['secret'], codes[:new_code].to_s)

      current_user.update!(
        otp_secret_key: candidate.otp_secret_key,
        totp_timestamp: candidate.totp_timestamp,
        direct_otp: nil,
        direct_otp_sent_at: nil,
        second_factor_attempts_count: 0
      )
      updated = true
    end

    if updated
      session.delete(:pending_totp)
      render json: { success: 'TOTP configuration saved.' }
    else
      render json: { error: 'Second-factor verification failed.' }, status: :unauthorized
    end
  end
end
```

Connect these actions in `config/routes.rb`:

```ruby
post 'account/totp/setup', to: 'account#new_totp'
patch 'account/totp', to: 'account#update_totp'
```

Show the provisioning URI as a QR code and ask for both codes before submitting
the update. Users without TOTP receive a fresh direct code through your
`send_two_factor_authentication_code` implementation. Apply the same existing
factor check to other sensitive changes, and save the user after a successful
TOTP check to persist its replay timestamp.


### Example App

[TwoFactorAuthenticationExample](https://github.com/Houdini/TwoFactorAuthenticationExample)


### Example user actions

to use an ENV VAR for the 2FA encryption key:

config.otp_secret_encryption_key = ENV['OTP_SECRET_ENCRYPTION_KEY']

to set up TOTP for Google Authenticator for user:

Use the `new_totp` and `update_totp` actions above to prepare the QR code and
verify both the current factor and the new authenticator code. Keep the pending
secret separate from `current_user.otp_secret_key` until both checks succeed.

Encrypted database fields are persisted when the update action saves the user.
Rails console access also requires `OTP_SECRET_ENCRYPTION_KEY` to be set.

additional note:
 
   ```
   current_user.otp_secret_key
   ```
   
This returns the OTP secret key in plaintext for the user (if you have set the env var) in the console
the string used for generating the QR given to the user for their Google Auth is something like:

otpauth://totp/LABEL?secret=p6wwetjnkjnrcmpd    (example secret used here)

where LABEL should be something like "example.com (Username)", which shows up in their GA app to remind them the code is for example.com

to set TOTP to DISABLED for a user account:

After verifying the existing factor as described above:

```ruby
current_user.update!(
  otp_secret_key: nil,
  totp_timestamp: nil,
  direct_otp: nil,
  direct_otp_sent_at: nil,
  second_factor_attempts_count: 0
)
current_user.direct_otp? # => false
current_user.totp_enabled? # => false
```

This disables TOTP and leaves the attempt counter at an integer value. Direct
OTP authentication remains required unless `need_two_factor_authentication?`
returns `false`.
