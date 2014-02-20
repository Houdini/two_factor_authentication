## Two factor authentication for Devise

## Features

* control sms code pattern
* configure max login attempts
* per user level control if he really need two factor authentication
* your own sms logic

## Configuration

### Initial Setup

In a Rails environment, require the gem in your Gemfile:

    gem 'two_factor_authentication'

Once that's done, run:

    bundle install


### Automatic installation

In order to add two factor authorisation to a model, run the command:

    bundle exec rails g two_factor_authentication MODEL

Where MODEL is your model name (e.g. User or Admin). This generator will add `:two_factor_authenticatable` to your model
and create a migration in `db/migrate/`, which will add `::second_factor_pass_code` and `:second_factor_attempts_count` to your table.
Finally, run the migration with:

    bundle exec rake db:migrate

Add the following line to your model to fully enable two-factor auth:

    has_one_time_password

Set config values if desired for maximum second factor attempts count and allowed time drift for one-time passwords:

    config.max_login_attempts = 3
    config.allowed_otp_drift_seconds = 30

Override the method to send one-time passwords in your model, this is automatically called when a user logs in:

    def send_two_factor_authentication_code
      # use Model#otp_code and send via SMS, etc.
    end

### Manual installation

To manually enable two factor authentication for the User model, you should add two_factor_authentication to your devise line, like:

```ruby
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :two_factor_authenticatable
```

Add the following line to your model to fully enable two-factor auth:

    has_one_time_password

Set config values if desired for maximum second factor attempts count and allowed time drift for one-time passwords:

    config.max_login_attempts = 3
    config.allowed_otp_drift_seconds = 30

Override the method to send one-time passwords in your model, this is automatically called when a user logs in:

    def send_two_factor_authentication_code
      # use Model#otp_code and send via SMS, etc.
    end

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
