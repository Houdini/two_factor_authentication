class HomeController < ApplicationController
  before_action :authenticate_user!, only: :dashboard

  def index
  end

  def dashboard
    respond_to do |format|
      format.html
      format.json do
        render json: {success: true}
      end
      format.xml do
        render xml: "<success></success>"
      end
    end
  end

end
