class Sec223fRefinanceController < ApplicationController
  
  def loan
    @loan = Sec223fRefinance::Sec223fRefinance.new(params) # TODO: settle status of params...
    
    if @loan.valid?
      render :json => @loan.json_result
    else
      render :json => @loan.json_errors
    end
  end
  
end
