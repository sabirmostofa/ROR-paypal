require 'cgi'
require 'profile'
require 'caller'
class RpdetailsController < ApplicationController
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
    redirect_to :action => 'RPdetails', :profileId => params[:profileId]
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :action => 'index' 
  end

  def RPdetails
	  @profileId=params[:profileId]
  end

   def get_rpdetails 
      @caller =  PayPalSDKCallers::Caller.new(false)
      @transaction = @caller.call(
      {
        :method          => 'GetRecurringPaymentsProfileDetails',
        :PROFILEID      =>params[:profileID],
        :USER  =>  @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT  
      }
      ) 
    if @transaction.success?       
      session[:rpprofiledetail_response]=@transaction.response 
      redirect_to :controller => 'rpdetails',:action => 'details'
       
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
    end
    rescue Errno::ENOENT => exception
      flash[:error] = exception
      redirect_to :controller => 'wppro', :action => 'exception'
    end   

  def details
	      @response = session[:rpprofiledetail_response]
    @profileId =  @response["PROFILEID"]
    @status = @response["STATUS"]
    @description = @response["DESC"]
    @AUTOBILLOUTAMT =@response["AUTOBILLOUTAMT"]
    @MAXFAILEDPAYMENTS=@response["MAXFAILEDPAYMENTS"]
    @SUBSCRIBERNAME =  @response["SUBSCRIBERNAME"]
    @PROFILESTARTDATE = @response["PROFILESTARTDATE"]
    @NEXTBILLINGDATE = @response["NEXTBILLINGDATE"]
    @NUMCYCLESCOMPLETED =@response["NUMCYCLESCOMPLETED"]
    @NUMCYCLESREMAINING=@response["NUMCYCLESREMAINING"]
    @OUTSTANDINGBALANCE =  @response["OUTSTANDINGBALANCE"]
    @FAILEDPAYMENTCOUNT = @response["FAILEDPAYMENTCOUNT"]
    @TRIALAMTPAID = @response["TRIALAMTPAID"]
    @REGULARAMTPAID =@response["REGULARAMTPAID"]
    @AGGREGATEAMT=@response["AGGREGATEAMT"]
    @AGGREGATEOPTIONALAMT =  @response["AGGREGATEOPTIONALAMT"]
    @FINALPAYMENTDUEDATE = @response["FINALPAYMENTDUEDATE"]
    @TIMESTAMP = @response["TIMESTAMP"]
    @CORRELATIONID =@response["CORRELATIONID"]
    @ACK=@response["ACK"]
    @VERSION =  @response["VERSION"]
    @BUILD = @response["BUILD"]
    @BILLINGFREQUENCY = @response["BILLINGFREQUENCY"]
    @TOTALBILLINGCYCLES =@response["TOTALBILLINGCYCLES"]
    @CURRENCYCODE=@response["CURRENCYCODE"]
    @AMT =  @response["AMT"]
    @TAXAMT = @response["TAXAMT"]
    @SHIPPINGAMT =  @response["SHIPPINGAMT"]
    @BILLINGPERIOD = @response["BILLINGPERIOD"]
    @REGULARBILLINGPERIOD = @response["REGULARBILLINGPERIOD"]
    @REGULARBILLINGFREQUENCY =@response["REGULARBILLINGFREQUENCY"]
    @REGULARTOTALBILLINGCYCLES=@response["REGULARTOTALBILLINGCYCLES"]
    @REGULARCURRENCYCODE =  @response["REGULARCURRENCYCODE"]
    @REGULARAMT = @response["REGULARAMT"]
    @REGULARSHIPPINGAMT = @response["REGULARSHIPPINGAMT"]
    @REGULARTAXAMT =@response["REGULARTAXAMT"]
    @ACCT=@response["ACCT"]
    @CREDITCARDTYPE =  @response["CREDITCARDTYPE"]
    @EXPDATE = @response["EXPDATE"]
    @FIRSTNAME = @response["FIRSTNAME"]
    @LASTNAME =@response["LASTNAME"]
    @STREET=@response["STREET"]
    @CITY =  @response["CITY"]
    @STATE = @response["STATE"]
    @ZIP = @response["ZIP"]
    @COUNTRYCODE =@response["COUNTRYCODE"]
    @COUNTRY=@response["COUNTRY"]
    @ADDRESSOWNER = @response["ADDRESSOWNER"]
    @ADDRESSSTATUS =@response["ADDRESSSTATUS"]
    @PAYERSTATUS=@response["PAYERSTATUS"] 
  end

end
