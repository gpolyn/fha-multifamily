class Sec223fRefinanceApiWrapper
  include Refinance
end

class Api::Beta1::Sec223fRefinanceController < Api::ApplicationController
  
  # respond_to :json
  
  def loan
    data = ActiveSupport::JSON.decode(request.body.read)
    @loan = Sec223fRefinanceApiWrapper.new(data)

    if @loan.valid?
      render :json => @loan.to_json
    else
      render :json=>@loan.errors_to_json, :status=>400
    end
    rescue Exception => e
      # TODO: add logging (I think it should capture the point of failure in the wrapper)
      error = {:error=>"Data required to fulfill the request is currently unavailable"}
      render :json => error.to_json, :status=>500
  end
  
end