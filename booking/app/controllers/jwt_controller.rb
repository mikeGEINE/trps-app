class JwtController < ApplicationController
  skip_before_action :validate_token
  def new
    if cookies[:token].present?
      return
    end
    else
      cookies[:token] = GenerateTokens.new.call.value!
    end
  end
  
  def acs
  end

  def logout
  end
end
