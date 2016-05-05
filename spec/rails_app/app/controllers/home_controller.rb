class HomeController < ApplicationController
  if Rails::VERSION::MAJOR >= 4
    before_action :authenticate_user!, only: :dashboard
  else
    before_filter :authenticate_user!, only: :dashboard
  end

  def index
  end

  def dashboard
  end

end
