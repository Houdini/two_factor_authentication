# Two factor authentication for Devise
XXX
YYY

[![Build Status](https://travis-ci.org/Houdini/two_factor_authentication.svg?branch=master)](https://travis-ci.org/Houdini/two_factor_authentication)
[![Code Climate](https://codeclimate.com/github/Houdini/two_factor_authentication.png)](https://codeclimate.com/github/Houdini/two_factor_authentication)

## Features

* configurable OTP code digit length
* configurable max login attempts
* customizable logic to determine if a user needs two factor authentication
* customizable logic for sending the OTP code to the user
* configurable period where users won't be asked for 2FA again
* option to encrypt the OTP secret key in the database, with iv and salt

## Configuration

### Initial Setup

In a Rails environment, require the gem in your Gemfile:

    gem 'two_factor_authentication'

Once that's done, run:

    bundle install

Note that Ruby 2.0 or greater is required.

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

#### Manual initial setup
If you prefer to set up the model and migration manually, add the
`:two_factor_authentication` option to your existing devise options, such as:

```ruby
devise :database_authenticatable, :registerable, :recoverable, :rememberable,
       :trackable, :validatable, :two_factor_authenticatable
```

Then create your migration file using the Rails generator, such as:

```
rails g migration AddTwoFactorFieldsToUsers second_factor_attempts_count:integer encrypted_otp_secret_key:string:index encrypted_otp_secret_key_iv:string encrypted_otp_secret_key_salt:string
```

Open your migration file (it will be in the `db/migrate` directory and will be
named something like `20151230163930_add_two_factor_fields_to_users.rb`), and
add `unique: true` to the `add_index` line so that it looks like this:

```ruby
add_index :users, :encrypted_otp_secret_key, unique: true
```
Save the file.

#### Complete the setup
Run the migration with:

    bundle exec rake db:migrate

Add the following line to your model to fully enable two-factor auth:

    has_one_time_password(encrypted: true)

Set config values in `config/initializers/devise.rb`:

```ruby
config.max_login_attempts = 3  # Maximum second factor attempts count.
config.allowed_otp_drift_seconds = 30  # Allowed time drift between client and server.
config.otp_length = 6  # OTP code length
config.remember_otp_session_for_seconds = 30.days  # Time before browser has to enter OTP code again. Default is 0.
config.otp_secret_encryption_key = ENV['OTP_SECRET_ENCRYPTION_KEY']
```
The `otp_secret_encryption_key` must be a random key that is not stored in the
DB, and is not checked in to your repo. It is recommended to store it in an
environment variable, and you can generate it with `bundle exec rake secret`.

Override the method to send one-time passwords in your model. This is
automatically called when a user logs in:

```ruby
def send_two_factor_authentication_code
  # use Model#otp_code and send via SMS, etc.
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
You can generate provisioning uris by invoking the following method on your model:

```ruby
user.provisioning_uri # This assumes a user model with an email attribute
```

This provisioning uri can then be turned in to a QR code if desired so that
users may add the app to Google Authenticator easily.  Once this is done, they
may retrieve a one-time password directly from the Google Authenticator app as
well as through whatever method you define in
`send_two_factor_authentication_code`.

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

<%= link_to "Sign out", destroy_user_session_path, :method => :delete %>

```

#### Updating existing users with OTP secret key

If you have existing users that need to be provided with a OTP secret key, so
they can use two factor authentication, create a rake task. It could look like this one below:

```ruby
desc 'rake task to update users with otp secret key'
task :update_users_with_otp_secret_key  => :environment do
  User.find_each do |user|
    user.otp_secret_key = ROTP::Base32.random_base32
    user.save!
    puts "Rake[:update_users_with_otp_secret_key] => OTP secret key set to '#{key}' for User '#{user.email}'"
  end
end
```
Then run the task with `bundle exec rake update_users_with_otp_secret_key`

#### Adding the OTP encryption option to an existing app

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
   class PopulateEncryptedOtpFields < ActiveRecord::Migration
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
          user.otp_secret_key = ROTP::Base32.random_base32
          user.save!
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

1. Remove `(encrypted: true)` from `has_one_time_password`

2. Roll back the last 3 migrations (assuming you haven't added any new ones
after them):
   ```
   bundle exec rake db:rollback STEP=3
   ```

#### Executing some code after the user signs in and before they sign out

In some cases, you might want to perform some action right after the user signs
in, but before the OTP is sent, and also right before the user signs out. One
scenario where you would need this is if you are requiring users to confirm
their phone number first before they can receive an OTP. If they enter a wrong
number, then sign out or close the browser before they confirm, they won't be
able to confirm their real number. To solve this problem, we need to be able to
reset their unconfirmed number before they sign out or sign in, and before the
OTP code is sent.

To define this action, create a `#{user.class}OtpSender` class that takes the
current user as its parameter, and defines a `#reset_otp_state` instance method.
For example, if your user's class is `User`, you would create a `UserOtpSender`
class, like this:
```ruby
class UserOtpSender
  def initialize(user)
    @user = user
  end

  def reset_otp_state
    if @user.unconfirmed_mobile.present?
      @user.update(unconfirmed_mobile: nil)
    end
  end
end
```
If you have different types of users in your app (for example, User and Admin),
and you need different logic for each type of user, create a second class for
your admin user, such as `AdminOtpSender`, with its own logic for
`#reset_otp_state`.

### Example App

[TwoFactorAuthenticationExample](https://github.com/Houdini/TwoFactorAuthenticationExample)
