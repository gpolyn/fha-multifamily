class Api::Beta1::ApiKeysController < ApplicationController
  
  respond_to :html
  
  def new
  end
  
  def create
    if verify_recaptcha
      @key = ApiKey.get_instance
      
      if @key.save
        redirect_to :action => :show, :id => @key.value # maybe just render something with key?
      else
        err_msg = "You may not be a machine, but we failed on your key creation -- please try again later"
        flash[:error] = err_msg
        redirect_to :action => :new # maybe render a failure page?
      end
    else
      # log it...
      err_msg = "You failed captcha -- maybe you're a machine."
      flash[:error] = err_msg
      redirect_to :action => :new
    end
  end
  
  def show
    # TODO
  end
  
end
