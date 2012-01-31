class Api::ApplicationController < ApplicationController
  
  # layout "api"
  
  before_filter :check_for_valid_key
  after_filter :handle_api_key_times_used_and_update_response_header
  
  protected
  
  attr_accessor :api_key
  
  def check_for_valid_key
    handle_missing_api_key and return unless params[:api_key]
  
    self.api_key = ApiKey.find_by_value params[:api_key]
    handle_invalid_api_key and return unless api_key && api_key.valid? #&& api_key.would_exceed_maximum_uses
    
    rescue Exception
      # log
      error = {:error=>"Api key search failure"}
      render :json => error.to_json, :status=>500
  end
  
  def handle_api_key_times_used_and_update_response_header
    unless response.status >= 200 and response.status < 300
      set_api_key_uses_remaining_header api_key.uses_remaining and return
    end
      
    set_api_key_uses_remaining_header api_key.get_uses_remaining_and_increment_times_used_by_1
    
    if api_key.uses_remaining == 0
      api_key.destroy
    elsif api_key.save
      set_api_key_uses_remaining_header api_key.uses_remaining
    else
      # log, shithead
    end
  end
  
  private
  
  def set_api_key_uses_remaining_header(val)
    response.headers['Api-key-uses-remaining'] = val.to_s
  end
  
  def handle_missing_api_key
    render_401 "No api key supplied"
  end
  
  def handle_invalid_api_key
    render_401 "Invalid api key"
  end
  
  def render_401(error_msg)
    render :json => {:error=>error_msg}, :status=>401
  end
  
end
