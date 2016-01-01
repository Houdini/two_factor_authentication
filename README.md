# Two factor authentication for Devise

[![Build Status](https://travis-ci.org/Houdini/two_factor_authentication.svg?branch=master)](https://travis-ci.org/Houdini/two_factor_authentication)
[![Code Climate](https://codeclimate.com/github/Houdini/two_factor_authentication.png)](https://codeclimate.com/github/Houdini/two_factor_authentication)

## Features

* control sms code pattern
* configure max login attempts
* per user level control if he really need two factor authentication
* your own sms logic
* configurable period where users won't be asked for 2FA again

## Configuration

### Initial Setup

In a Rails environment, require the gem in your Gemfile:

    gem 'two_factor_authentication'

Once that's done, run:

    bundle install

### Automatic installation

In order to add two factor authentication to a model, run the command:

    bundle exec rails g two_factor_authentication MODEL

Where MODEL is your model name (e.g. User or Admin). This generator will add `:two_factor_authenticatable` to your model
and create a migration in `db/migrate/`, which will add `:otp_secret_key` and `:second_factor_attempts_count` to your table.
Finally, run the migration with:

    bundle exec rake db:migrate

Add the following line to your model to fully enable two-factor auth:

    has_one_time_password

Set config values, if desired:

```ruby
config.max_login_attempts = 3  # Maximum second factor attempts count
config.allowed_otp_drift_seconds = 30  # Allowed time drift
config.otp_length = 6  # OTP code length
config.remember_otp_session_for_seconds = 30.days  # Time before browser has to enter OTP code again
```

Override the method to send one-time passwords in your model, this is automatically called when a user logs in:

```ruby
def send_two_factor_authentication_code
  # use Model#otp_code and send via SMS, etc.
end
```

### Manual installation

To manually enable two factor authentication for the User model, you should add two_factor_authentication to your devise line, like:

```ruby
devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable, :validatable, :two_factor_authenticatable
```

Add the following line to your model to fully enable two-factor auth:

    has_one_time_password

Set config values to devise.rb, if desired:

```ruby
config.max_login_attempts = 3  # Maximum second factor attempts count
config.allowed_otp_drift_seconds = 30  # Allowed time drift
config.otp_length = 6  # OTP code length
config.remember_otp_session_for_seconds = 30.days  # Time before browser has to enter OTP code again
```

Override the method to send one-time passwords in your model, this is automatically called when a user logs in:

```ruby
def send_two_factor_authentication_code
  # use Model#otp_code and send via SMS, etc.
end
```


### Customisation and Usage

By default second factor authentication enabled for each user, you can change it with this method in your User model:

```ruby
def need_two_factor_authentication?(request)
  request.ip != '127.0.0.1'
end
```

this will disable two factor authentication for local users

This gem is compatible with Google Authenticator (https://support.google.com/accounts/answer/1066447?hl=en).  You can generate provisioning uris by invoking the following method on your model:

    user.provisioning_uri #This assumes a user model with an email attributes

This provisioning uri can then be turned in to a QR code if desired so that users may add the app to Google Authenticator easily.  Once this is done they may retrieve a one-time password directly from the Google Authenticator app as well as through whatever method you define in `send_two_factor_authentication_code`

#### Overriding the view

The default view that shows the form can be overridden by first adding a folder named: "two_factor_authentication" inside "app/views/devise", in here you want to create a "show.html.erb" view.

The full path should be "app/views/devise/two_factor_authentication/show.html.erb"

```html
<h2>Hi, you received a code by email, please enter it below, thanks!</h2>

<%= form_tag([resource_name, :two_factor_authentication], :method => :put) do %>
  <%= text_field_tag :code %>
  <%= submit_tag "Log in!" %>
<% end %>

<%= link_to "Sign out", destroy_user_session_path, :method => :delete %>

```

#### Updating existing users with OTP secret key

If you have existing users that needs to be provided with a OTP secret key, so they can take benefit of the two factor authentication, create a rake. It could look like this one below:

```ruby
desc "rake task to update users with otp secret key"
task :update_users_with_otp_secret_key  => :environment do
	users = User.all

	users.each do |user|
		key = ROTP::Base32.random_base32
		user.update_attributes(:otp_secret_key => key)
		user.save
		puts "Rake[:update_users_with_otp_secret_key] => User '#{user.email}' OTP secret key set to '#{key}'"
	end
end
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

### Example

[TwoFactorAuthenticationExample](https://github.com/Houdini/TwoFactorAuthenticationExample)
