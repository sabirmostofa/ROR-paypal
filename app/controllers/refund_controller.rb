require 'cgi'
require 'profile'
require 'caller'
# Controller with actions for doing RefundTransaction API call. The name is chosen in consistent with other PayPal SDKs. 
class RefundController < ApplicationController
	  
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
    @transaction_id = params[:authorization_id] 
    @amount = params[:amount]
    @currency = params[:currency]
  end

# RefundTransaction API call  
  def do_refund     
    @caller =  PayPalSDKCallers::Caller.new(false)     
    req ={ 
      :method        => 'RefundTransaction',
      :refundtype    => params[:refundType].to_s,        
      :note          => params[:memo].to_s,
      :transactionid => params[:transactionID],
      :USER  =>  @@USER,
      :PWD   => @@PWD,
      :SIGNATURE => @@SIGNATURE,
      :SUBJECT => @@SUBJECT      
    }
    amt = params[:refundType].casecmp("Partial") == 0 ?  params[:amount].to_s : nil    
    req[:amt] = amt if (!amt.nil?)    
    
    @transaction = @caller.call(req)
    if @transaction.success?       
      session[:refund_response]=@transaction.response 
      redirect_to :controller => 'refund',:action => 'status'
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception' 
  end 

  def status
	@response = session[:refund_response]
  end

end
