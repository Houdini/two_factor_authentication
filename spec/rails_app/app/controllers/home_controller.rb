class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:dashboard, :secret]

  def index
  end

  def dashboard
  end

  # Responds to any format, to prove the 2FA check halts non-HTML/JSON requests
  def secret
    render plain: 'top secret'
  end

end
