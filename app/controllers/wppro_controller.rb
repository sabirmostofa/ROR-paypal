
require 'cgi'
class WpproController < ApplicationController
  def index
  end

  def error
	  @response = session[:paypal_error]
  end

  def exception
    @longmessage = flash[:error]
    p @longmessage
  end

end
