class HomeController < ApplicationController
  before_action :authenticate_user!, only: :dashboard

  def index
  end

  def dashboard
    respond_to do |format|
      format.html
      format.json { render json: {success: true} }
      format.xml { render xml: "<success></success>" }
    end
  end

end
