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


### Manual installation

To manually enable two factor authentication for the User model, you should add two_factor_authentication to your devise line, like:

```ruby
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :two_factor_authenticatable
```

Two default parameters

```ruby
  config.devise.login_code_random_pattern = /\w+/
  config.devise.max_login_attempts = 3
```

Possible random patterns

```ruby
/\d{5}/
/\w{4,8}/
```

see more https://github.com/benburkert/randexp

### Customisation

By default second factor authentication enabled for each user, you can change it with this method in your User model:

```ruby
  def need_two_factor_authentication?(request)
    request.ip != '127.0.0.1'
  end
```

this will disable two factor authentication for local users

Your send sms logic should be in this method in your User model:

```ruby
  def send_two_factor_authentication_code(code)
    puts code
  end
```

This example just puts the code in the logs.

#### Reset second factor attempts after a period of time

For example, if you have set this period in Settings.reset_attempts_period:

```ruby
  def max_login_attempts?
    check_attempts_reset
  
    second_factor_attempts_count >= self.class.max_login_attempts
  end
 
  def check_attempts_reset
    if Time.now - Settings.reset_attempts_period > updated_at
      update_attribute(:second_factor_attempts_count, 0)
    end
  end
```

### External dependencies

Randexp requires words files (Check if it is installed in /usr/share/dict/words or /usr/dict/words), 
you might need install it:

```bash
apt-get install wbritish # or whichever you require
```
