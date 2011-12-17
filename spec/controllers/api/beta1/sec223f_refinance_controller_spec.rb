require 'spec_helper'

describe Api::Beta1::Sec223fRefinanceController, "#loan" do
  
  it "should have expected route", :type=>:routing do
    assert_routing({:path=>"api/beta1/sec223f_refinance", :method =>:post}, 
                   {:controller=>"api/beta1/sec223f_refinance", :action =>"loan"})
  end

  describe "api key failure" do
    context "when key doesn't exist" do
      it "should do something..." do
        pending
      end 
    end
    context "when key exists but is stale" do
      it "should do something..." do
        pending
      end
    end
  end
  
  describe "success" do
    
    it "should be a success" do
      stub_out_api_key_before_and_after_filtering
      raw_post :loan, {}, minimum_params.to_json
      response.should be_success
    end
  end
  
  describe "request failure" do
    
    before(:each) do
      params = minimum_params
      params[:affordability] = true
      params[:metropolitan_area_waiver] = "US Moonbase, The Moon"
      params[:mortgage_interest_rate] = "invalid value, data type"
      stub_out_api_key_before_and_after_filtering
      raw_post :loan, {}, params.to_json
    end
    
    it "should have status code 400 expected message body" do
      response.status.should eql(400)
      expected = {:mortgage_interest_rate=>["is not a number"],
                  :affordability=>["is not an API-supported value"], 
                  :metropolitan_area_waiver=>["is not an API-supported value"]}
      response.body.should eql expected.to_json
    end
  end

  describe "server-side failure" do
    
    before(:each) do
      Sec223fRefinanceApiWrapper.should_receive(:new).and_raise(ActiveRecord::ActiveRecordError)
      stub_out_api_key_before_and_after_filtering
      raw_post :loan, {}, minimum_params.to_json
    end
    
    it "should have status code 500 and expected message body" do
      response.status.should eql(500)
      expected = {:error=>"Data required to fulfill the request is currently unavailable"}
      response.body.should eql expected.to_json
    end
    
  end
  
  protected
  
  def raw_post(action, params, body)
    @request.env['RAW_POST_DATA'] = body
    response = post(action, params)
    @request.env.delete('RAW_POST_DATA')
    response
  end
  
  def stub_out_api_key_before_and_after_filtering
    @controller.stub(:check_for_valid_key)
    @controller.stub(:handle_api_key_times_used_and_update_response_header)
  end
  
  private
  
  def minimum_params
    params = {}
    params['affordability'] = 'affordable'
    # params['loanParameters'] = {}
    # params['loanParameters']['purchase_price_of_project'] = 9_750_000
    params['existing_indebtedness'] = 8_000_000
    params['value_in_fee_simple'] = 10_000_000
    params['loan_request'] = 8_750_000
    params['metropolitan_area_waiver'] = 'New York, NY'
    params['annual_replacement_reserve_per_unit'] = 250
    
    mix = {}
    params['spaceUtilization'] = {'apartment' => {'unitMix'=> mix}}
    mix['number_of_two_bedroom_units'] = 20
    params['is_elevator_project'] = true
    
    # params['loanParameters']['mortgage_interest_rate'] = 4.5
    params['mortgage_interest_rate'] = 4.5
    params['operatingIncome'] = {'gross_residential_income' =>1000000, 'residential_occupancy_percent'=>93}
    params['operatingExpense'] = {'operating_expenses_is_percent_of_effective_gross_income'=>true, 'operating_expenses'=>40}
    # params['loanParameters']['term_in_months'] = 420
    params['term_in_months'] = 420
    params
  end

end
