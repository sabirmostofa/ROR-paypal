require 'cgi'
require 'profile'
require 'caller'
# Controller with actions for doing TransactionSearch API call. The name is chosen in consistent with other PayPal SDKs.
class TsController < ApplicationController
# to make long names shorter for easier access and to improve readability define the following variables
    @@profile = PayPalSDKProfiles::Profile
    #unipay credentials hash
    @@email=@@profile.unipay
    # merchant credentials hash
    @@cre=@@profile.credentials
    
  #condition to check if 3 token credentials are passed
  if((@@email.nil?) && (@@cre.nil? == false))
      @@USER = @@cre["USER"]
      @@PWD = @@cre["PWD"]
      @@SIGNATURE  = @@cre["SIGNATURE"]
      @@SUBJECT = ""
  end
  #condition to check if UNIPAY credentials are passed
  if((@@cre.nil?) && (@@email.nil? == false) )
      @@USER = ""
      @@PWD = ""
      @@SIGNATURE  = ""
      @@SUBJECT = @@email["SUBJECT"]
  end
  #condition to check if 3rd party credentials are passed
  if((@@cre.nil? == false) && (@@email.nil? == false))  
      @@USER = @@cre["USER"]
      @@PWD = @@cre["PWD"]
      @@SIGNATURE  = @@cre["SIGNATURE"]
      @@SUBJECT = @@email["SUBJECT"]
    end    
  
  def get_input
     reset_session
    @today = Date.today 
    @yesterday = @today-1   
  end

# TransactionSearch API call  
  def do_search      
    @caller =  PayPalSDKCallers::Caller.new(false)    
    startDate = "#{params[:startDate].to_s}T00:00:00Z"
    endDate = "#{params[:endDate].to_s}T24:00:00Z"     
    @transaction = @caller.call(
      { :method        => 'TransactionSearch',
        :trxtype       => 'Q',
        :startdate     => startDate,
        :enddate       => endDate,
        :transactionid => params[:transactionID] ,
        :USER  =>  @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT         
      }
    )      
    
   if @transaction.success?       
      session[:tsresult]=@transaction.response 
      redirect_to :controller => 'ts',:action => 'show'
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
  end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'
  end      

  def show
     @response = session[:tsresult] 
     reset_session
     @total_records = 0
     @response.each {|key| @total_records += 1 if (key.to_s.include? "L_TRANSACTIONID") }   
  end

end
