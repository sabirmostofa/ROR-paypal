require 'cgi'
require 'profile'
require 'caller'
# Controller with actions for doing gettransactionDetails API call. The name is chosen in consistent with other PayPal SDKs. 
class GtdController < ApplicationController
	   
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
    
  def search
	  reset_session
	  
  end

# GetTransactionDetails API call  
  def get_transaction_details         
    @tid = params[:transactionID]
    @caller =  PayPalSDKCallers::Caller.new(false) 
    @transaction = @caller.call(
      { :method        => 'gettransactionDetails',
        :transactionid => @tid,
        :USER  =>  @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT 
      }
     )    
        
    if @transaction.success?       
      session[:gtd_response]=@transaction.response 
      redirect_to :controller => 'gtd',:action => 'transaction_details'
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'
  end     

  def transaction_details
    @response = session[:gtd_response]     
    @transactionid=  @response["TRANSACTIONID"]
    @amt = @response["AMT"]
    @payerid = @response["PAYERID"]
    @firstname = @response["FIRSTNAME"]
    @lastname = @response["LASTNAME"]
    @paranttransactionid = @response["PARENTTRANSACTIONID"]
    @currencycode = @response["CURRENCYCODE"]
    @payerstatus = @response["PAYERSTATUS"]    
    @receiveremail = @response["RECEIVEREMAIL"]  
    @pendingreason = @response["PENDINGREASON"]
    @paymentstatus = @response["PAYMENTSTATUS"]
    @protectionEligibility = @response["PROTECTIONELIGIBILITY"]
  end

end
