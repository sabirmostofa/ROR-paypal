require 'cgi'
require 'profile'
require 'caller'
# Controller with actions for doing MassPay API call. The name is chosen in consistent with other PayPal SDKs. 
class MasspayController < ApplicationController
	
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
    
  def mass_pay
	  reset_session
	  @PAYMENT_ACTION=params[:PaymentAction]
  end
  # MassPay API call  
  def do_mass_pay     
    @caller =  PayPalSDKCallers::Caller.new(false)      
    req = { 
    :method       => 'MassPay',
    :emailsubject => params[:emailSubject],
    :receivertype => params[:receiverType],
    :USER  =>  @@USER,
    :PWD   => @@PWD,
    :SIGNATURE => @@SIGNATURE,
    :SUBJECT => @@SUBJECT
    }
    groups = {}
    params[:receiveremail].each_with_index { |e, i| groups["l_email#{i}"] = e }     
    params[:amount].each_with_index { |e, i| groups["l_amt#{i}"] = e }
    params[:uniqueID].each_with_index { |e, i| groups["l_uniqueid#{i}"] = e }
    params[:note].each_with_index { |e, i| groups["l_note#{i}"] = e }
    req.update(groups)
    @transaction = @caller.call(req)       
        
     if @transaction.success?       
      session[:mass_response]=@transaction.response 
      redirect_to :controller => 'masspay',:action => 'thanks'
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'
  end
  

  def thanks
	  @response = session[:mass_response] 
  end

end
