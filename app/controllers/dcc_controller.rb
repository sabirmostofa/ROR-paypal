require 'cgi'
require 'profile'
require 'caller'
class DccController < ApplicationController
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
    redirect_to :action => 'pay', :PaymentAction => params[:paymentaction]
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :action => 'index' 
  end

  def pay
	  @payment_action=params[:PaymentAction]
  end
  
    def do_DCC 
	    reset_session
   if (params[:dcc][:expDateMonth].to_s.length == 1)
      @expMonth =   "0" + params[:dcc][:expDateMonth].to_s
    else
      @expMonth =    params[:dcc][:expDateMonth].to_s
    end     
    @caller =  PayPalSDKCallers::Caller.new(false)
    @transaction = @caller.call(
      {
        :method          => 'DoDirectPayment',
        :amt             => params[:amount],
        :currencycode    => 'USD',
        :paymentaction   => params[:PAYMENTACTION],
        :creditcardtype  => params[:creditCardType],
        :acct            => params[:creditCardNumber],
        :firstname       => params[:firstName].to_s,
        :lastname        => params[:lastName],
        :street          => params[:address1],
        :city            => params[:city],
        :state           => params[:dcc][:state],
        :zip             => params[:zip].to_s,
        :countrycode     => 'US',
        :expdate         => @expMonth+params[:dcc][:expDateYear].to_s,
        :cvv2            => params[:dcc][:cvv2Number].to_s,
        :USER  => @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT       
      }
    )       
     
   if @transaction.success?       
      session[:dcc_response]=@transaction.response 
      redirect_to :controller => 'dcc',:action => 'thanks'
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'
    end

  def thanks
    @response = session[:dcc_response]
    @transactionId =  @response["TRANSACTIONID"]
    @amount = @response["AMT"]
    @avsCode = @response["AVSCODE"]
    @cvv2Match = @response["CVV2MATCH"]
  end

end
