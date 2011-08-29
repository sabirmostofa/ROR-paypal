require 'cgi'
require 'profile'
require 'caller'
# Controller with actions for doing DoDirectPayment API call. The name is chosen in consistent with other PayPal SDKs. 
class Threedsecure::ThreedsecureController < ApplicationController
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
    redirect_to :action => 'pay', :PaymentAction => params[:paymentaction]
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :action => 'index' 
  end
  
    def pay
    @payment_action=params[:PaymentAction]
  end
  
  
  # DoDirectPayment API call  
  def do_DCC3D        
    if (params[:threeDsecure][:expDateMonth].to_s.length == 1)
      @expMonth =   "0" + params[:threeDsecure][:expDateMonth].to_s
    else
      @expMonth =    params[:threeDsecure][:expDateMonth].to_s
    end   
    if (params[:threeDsecure][:startDateMonth].to_s.length == 1)
      @startMonth =   "0" + params[:threeDsecure][:startDateMonth].to_s
    else
      @startMonth =    params[:threeDsecure][:startDateMonth].to_s
    end     
    @caller =  PayPalSDKCallers::Caller.new(false)
    @transaction = @caller.call(
      {
        :method          => 'DoDirectPayment',
        :paymentaction   => params[:PAYMENTACTION],
        :amt             => params[:amount],
        :creditcardtype  => params[:creditCardType],
        :acct            => params[:creditCardNumber],
        :expdate         => @expMonth+params[:threeDsecure][:expDateYear].to_s,
        :cvv2            => params[:cvv2Number].to_s,
        :firstname       => params[:firstName].to_s,
        :lastname        => params[:lastName],
        :street          => params[:address1],
        :city            => params[:city],
        :state           => params[:state],
        :zip             => params[:zip].to_s,
        :countrycode     => 'GB',
        :currencycode    => params[:currency],
        :startdate         => @startMonth+params[:threeDsecure][:startDateYear].to_s,
        :ECI3DS        => params[:eciFlag],
        :CAVV          => params[:cavv],
        :XID            => params[:xid],
        :MPIVENDOR3DS           => params[:enrolled],
        :AUTHSTATUS3DS=> params[:pAResStatus],
        :USER  => @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT
      }
    )       
     
   if (@transaction.success?)
      session[:threed_response]=@transaction.response 
      redirect_to :controller => 'threedsecure',:action => 'thanks'
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => '/wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => '/wppro', :action => 'exception'
  end

  def thanks
    @response = session[:threed_response]
    flash[:message] = @response
    @transactionId =  @response["TRANSACTIONID"]
    @amount = @response["AMT"]
  end

end
