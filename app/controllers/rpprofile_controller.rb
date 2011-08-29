require 'cgi'
require 'profile'
require 'caller'
class RpprofileController < ApplicationController
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
     redirect_to :action => 'RPprofile'
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :action => 'index' 
  end
  
     def do_rpprofile       
    if (params[:rpprofile][:expDateMonth].to_s.length == 1)
      @expMonth =   "0" + params[:rpprofile][:expDateMonth].to_s
    else
      @expMonth =    params[:rpprofile][:expDateMonth].to_s
      @expDate =    params[:rpprofile][:expDateDay].to_s
      @expYear =    params[:rpprofile][:expDateYear].to_s
    end   
    @caller =  PayPalSDKCallers::Caller.new(false)
    @transaction = @caller.call(
      {
        :method          => 'CreateRecurringPaymentsProfile',
        :amt             => params[:amount],
        :currencycode    => 'USD',
        :creditcardtype  => params[:creditCardType],
        :acct            => params[:creditCardNumber],
        :firstname       => params[:firstName].to_s,
        :lastname        => params[:lastName],
        :street          => params[:address1],
        :city            => params[:city],
        :state           => params[:rpprofile][:state],
        :zip             => params[:zip].to_s,
        :countrycode     => 'US',
        :expdate         => @expMonth+params[:rpprofile][:expDateYear].to_s,
        :cvv2            => params[:cvv2Number].to_s  ,
        :DESC           => params[:description].to_s,    
        :PROFILESTARTDATE      =>@expYear+"-"+@expMonth+"-"+@expDate +"T01:00:00,0Z",     
        :BILLINGPERIOD           => params[:BILLINGPERIOD],
        :BILLINGFREQUENCY            => params[:BILLINGFREQUENCY],
        :TOTALBILLINGCYCLES            => params[:TOTALBILLINGCYCLES],
        :ADDRESSSTATUS             => 'Confirmed',
        :USER  =>  @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT 
      }
    )       
     
   if @transaction.success?       
     
      session[:rpprofile_response]=@transaction.response 
      redirect_to :controller => 'rpprofile',:action => 'thanks'
       
    else
    session[:paypal_error]=@transaction.response
    redirect_to :controller => 'wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'
  end
  

  def thanks
    @response = session[:rpprofile_response]
    @profileId =  @response["PROFILEID"]
    @ProfileStatus =  @response["PROFILESTATUS"]
    @token =  @response["TOKEN"]
    @TIMESTAMP= @response["TIMESTAMP"]
    @CORRELATIONID= @response["CORRELATIONID"]
    @ACK= @response["ACK"]
    @VERSION= @response["VERSION"]
    @BUILD= @response["BUILD"]
  end

end
