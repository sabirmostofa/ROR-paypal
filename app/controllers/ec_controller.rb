require 'cgi'
require 'profile'
require 'caller'
# Controller with actions for doing ExpressCheckout API calls. The name is chosen in consistent with other PayPal SDKs. 
class EcController < ApplicationController
	
  # to make long names shorter for easier access and to improve readability define the following variables
    @@profile = PayPalSDKProfiles::Profile
    #unipay credentials hash
    @@email=@@profile.unipay
    # merchant credentials hash
    @@cre=@@profile.credentials
    @@DEV_CENTRAL_URL=@@profile.DEV_CENTRAL_URL
    
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
     redirect_to :action => :buy, :PaymentAction => params[:paymentaction]
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception' 
  end

  def buy
    @payment_action=params[:PaymentAction]
    session[:payment_action]=@payment_action
    @DEV_CENTRAL_URL=@@DEV_CENTRAL_URL
  end
  
  # SetExpressCheckout API call  
  def ec_step1 
    @ECRedirectURL=PayPalSDKProfiles::Profile.PAYPAL_EC_URL 
    @host=request.host.to_s
    @port=request.port.to_s   
    @cancelURL="http://#{@host}:#{@port}"
    @returnURL="http://#{@host}:#{@port}/ec/ec_step2"            
    session[:ccode]=params[:currency]    
    @itemAmt = 0.0
    @itemAmt = params[:L_AMT1].to_f*params[:L_QTY1].to_f+params[:L_AMT0].to_f*params[:L_QTY0].to_f
    # amt = itemamount+ shippingamt+shippingdisc+taxamt+insuranceamount;
    @amt     = @itemAmt+5.00+2.00+1.00
    @maxAmt  = @amt+35.00
 	
    @caller =  PayPalSDKCallers::Caller.new(false)    
    req = {  :method                 		=> 'SetExpressCheckout',
            :paymentaction  =>params[:PAYMENTACTION],
    	     :currencycode           		=> params[:currency],
    	     :cancelurl              		=> @cancelURL,
             :returnurl              		=> @returnURL,
             :SHIPDISCAMT            		=> '-3.00',
             :SHIPPINGAMT            		=> '8.00',
             :CALLBACK               		=> 'https://www.ppcallback.com/callback.pl',
             :ADDRESSOVERRIDE			=> '1',
             :INSURANCEOPTIONOFFERED 	 	=> 'true',
             :INSURANCEAMT           	 	=> '1.00',
             :L_SHIPPINGOPTIONISDEFAULT0 	=> 'false',
             :L_SHIPPINGOPTIONNAME0             => 'UPS Ground',
             :L_SHIPPINGOPTIONAMOUNT0           => '3.00',
	     :L_SHIPPINGOPTIONISDEFAULT1        => 'true',
	     :L_SHIPPINGOPTIONNAME1             => 'UPS Air',
	     :L_SHIPPINGOPTIONAMOUNT1           => '8.00',
	     :CALLBACKTIMEOUT                   => '5',
	     :SHIPTONAME				=> params[:RECEIVERNAME],
	     :SHIPTOSTREET			=> params[:SHIPTOSTREET],
	     :SHIPTOCITY 			=> params[:SHIPTOCITY],
	     :SHIPTOSTATE			=> params[:SHIPTOSTATE],
	     :SHIPTOCOUNTRY			=> params[:SHIPTOCOUNTRY],
	     :SHIPTOCOUNTRYCODE		=> 'US',
	     :SHIPTOZIP				=> params[:SHIPTOZIP],
	     :ITEMAMT                           => @itemAmt,
	     :TAXAMT                            => "2.00",
	     :AMT				=> @amt,
	     :MAXAMT				=> @maxAmt,
	     :L_NAME0 				=> params[:L_NAME0],
	     :L_NAME1 				=> params[:L_NAME1],
	     :L_QTY0 				=> params[:L_QTY0],
	     :L_QTY1 				=> params[:L_QTY1],
	     :L_AMT0 				=> params[:L_AMT0],
	     :L_AMT1 				=> params[:L_AMT1],
       :USER  =>  @@USER,
       :PWD   => @@PWD,
       :SIGNATURE => @@SIGNATURE,
       :SUBJECT => @@SUBJECT 
    }
    
    
   @transaction = @caller.call(req)  
   
   if @transaction.success? 
      @token = @transaction.response["TOKEN"].to_s
      session[:token] = @token
      redirect_to(@ECRedirectURL+@token)
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
    end
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'
        
  end
# GetExpressCheckoutDetails API call   
  def ec_step2
    @caller =  PayPalSDKCallers::Caller.new(false)
    @token=params[:token].to_s      
    @transaction = @caller.call(
      {
        :method => 'GetExpressCheckoutDetails',
        :token  => @token,
        :USER  =>  @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT 
      }
    )    
         
    @payerid= @transaction.response["PAYERID"].to_s    
    session[:payerid] = @payerid
    @transaction = @caller.call(
      {
        :method  => 'GetExpressCheckoutDetails',
        :token   => @token,
        :payerid => @payerid,
        :USER  =>  @@USER,
       :PWD   => @@PWD,
       :SIGNATURE => @@SIGNATURE,
       :SUBJECT => @@SUBJECT         
      }
    )   
    if @transaction.success?  
      session[:ecdetails]=@transaction.response 
      redirect_to :action => 'ecdetails'
    else
      session[:paypal_error]=@transaction.response
      redirect_to :controller => 'wppro', :action => 'error'
    end
    rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'  
         
  end  

  def ecdetails
    @response = session[:ecdetails]
    @amount= @response["AMT"]         
    @shiptostreet=@response["SHIPTOSTREET"]
    @shiptostreet2=@response["SHIPTOSTREET2"]
    @shiptocity=@response["SHIPTOCITY"]
    @shiptostate=@response["SHIPTOSTATE"]
    @shiptozip=@response["SHIPTOZIP"]  
    @shiptocountry=@response["SHIPTOCOUNTRYCODE"] 
    @shippingcalculationmode=@response["SHIPPINGCALCULATIONMODE"]
    @shippingoptionamount=@response["SHIPPINGOPTIONAMOUNT"]
    @shippingoptionname=@response["SHIPPINGOPTIONNAME"]
    session[:AMT]=@amount
    session[:ccode]=@response["CURRENCYCODE"]
  end
  
   def ec_step3   
    @caller =  PayPalSDKCallers::Caller.new(false)
	 @@token         = session[:token]
        @@payerid       = session[:payerid]
	@@paymentaction =session[:payment_action]
	@@AMT=session[:AMT]
	@@CURRENCYCODE=session[:ccode]
	reset_session
    @transaction = @caller.call(
      {
        :method        => 'DOExpressCheckoutPayment',
        :token         => @@token,
        :payerid       => @@payerid,
        :amt           => @@AMT.to_s,
        :currencycode  => @@CURRENCYCODE,
        :paymentaction => @@paymentaction,
        :USER  =>  @@USER,
        :PWD   => @@PWD,
        :SIGNATURE => @@SIGNATURE,
        :SUBJECT => @@SUBJECT 
      }
    )    
    
    if @transaction.success?  
         session[:step3]=@transaction.response
         redirect_to :action => 'thanks' 
        else
          session[:paypal_error]=@transaction.response
          redirect_to :controller => 'wppro', :action => 'error'
    end    
    rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :controller => 'wppro', :action => 'exception'  
           
  end  

  def thanks
    @response = session[:step3]    
    @transID=@response["TRANSACTIONID"]
    @price = @response["CURRENCYCODE"].to_s+" "+@response["AMT"].to_s
  end

end
