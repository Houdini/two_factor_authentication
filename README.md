## Two factor authentication for Devise

## Features

* control sms code pattern
* configure max login attempts
* per user level control if he really need two factor authentication
* your own sms logic

## Configuration

To enable two factor authentication for User model, you should add two_factor_authentication to your devise line, like:

```ruby
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :two_factor_authenticatable
```

Two default parameters

```ruby
  config.login_code_random_pattern = /\w+/
  config.max_login_attempts = 3
```

Possible random patterns

```ruby
/\d{5}/
/\w{4,8}/
```

see more https://github.com/benburkert/randexp

By default second factor authentication enabled for each user, you can change it with this method in your User mdoel:

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

This example just puts code in logs
