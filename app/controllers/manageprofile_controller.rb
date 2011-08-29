require 'cgi'
require 'profile'
require 'caller'
class ManageprofileController < ApplicationController
	    
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
    
  def begin
   reset_session
     redirect_to :action => 'manage'
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :action => 'index'
  end

 def change_rpdetails
    @caller =  PayPalSDKCallers::Caller.new(false)
    @transaction = @caller.call(
      {
        :method          => 'ManageRecurringPaymentsProfileStatus',
        :PROFILEID      =>params[:profileID].to_s ,
        :ACTION => params[:Action],
        :USER  =>  @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT
      }
    )       
     
   if @transaction.success?       
      session[:manage_response]=@transaction.response 
      redirect_to :controller => 'manageprofile',:action => 'changedProfile'
       
    else
    session[:paypal_error]=@transaction.response
    redirect_to :controller => 'wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'
  end 

  def changedProfile
    @response = session[:manage_response]
    @profileId =  @response["PROFILEID"]
  end

end
