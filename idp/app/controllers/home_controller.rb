class HomeController < ApplicationController
  def index
  end

  def post
    flash[:notice] = "Token generated! #{params[:access_token]}"
    redirect_to root_url
  end
end
