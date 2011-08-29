class RecurringpaymentController < ApplicationController
  def begin
     redirect_to :action => 'RPlinks'
  rescue Errno::ENOENT => exception
    flash[:error] = exception
    redirect_to :action => 'index' 
  end

end
