class HomeController < ApplicationController
  prepend_before_filter :store_location, only: :dashboard
  before_filter :authenticate_user!, only: :dashboard

  def index
  end

  def dashboard
  end

  private

  def store_location
    store_location_for(:user, dashboard_path)
  end
end
