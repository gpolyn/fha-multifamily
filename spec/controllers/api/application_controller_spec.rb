require 'spec_helper'

class TestApiController < Api::ApplicationController
  def some_action_with_a_200_response_code
    render :json => {:result =>"Some result for testing..."}, :status=>200
  end
  
  def some_action_with_a_300_response_code
    render :json => {:result =>"Some action that returns a 300 response for testing"}, :status=>300
  end
end

Rails.application.routes.draw do
  match 'test_route' => "test_api#some_action_with_a_200_response_code", :via=>:post
  match 'test_route_with_response_code_300' => "test_api#some_action_with_a_300_response_code", :via=>:post
end

describe TestApiController do
  
  let(:some_api_key){"gh34j7g91hsi234g"}
  let(:key){mock_model(ApiKey)}
  
  describe "after-filtering" do
    
    before(:each) do
      key.stub(:valid?).and_return true
      ApiKey.stub(:find_by_value).and_return key
    end
    
    context "when response code is in the 200 range" do
      
      after(:each) {response.code.should eql "200"}
      
      context "and when api key sucessfully saves" do
        
        it "should make two ordered calls on api_key and set decremented uses remaining in header" do
          key.stub(:save).and_return true
          key.should_receive(:get_uses_remaining_and_increment_times_used_by_1).ordered
          key.should_receive(:uses_remaining).ordered.and_return current_uses_remaining = 13
          post :some_action_with_a_200_response_code, :api_key=>some_api_key
          response.headers['Api-key-uses-remaining'].should == current_uses_remaining.to_s
        end
      end
      
      context "when api key fails to save" do
        
        it "should report the unaffected number of api key uses remaining in the header" do
          key.should_receive(:get_uses_remaining_and_increment_times_used_by_1).and_return expected = 13
          key.stub(:save).and_return false
          post :some_action_with_a_200_response_code, :api_key=> some_api_key
          response.headers['Api-key-uses-remaining'].should == expected.to_s
        end
        
        it "should log the failure" do
          pending
        end
      
      end
      
    end
    
    context "response is not in the 200 range" do
      
      before(:each) do
        @uses_remaining = 13
        key.should_receive(:uses_remaining).and_return @uses_remaining
      end
      
      after(:each) {response.code.should eql "300"}
      
      it "should not call get_uses_remaining_and_increment_times_used_by_1 on the key" do
        key.should_not_receive(:get_uses_remaining_and_increment_times_used_by_1)
        post :some_action_with_a_300_response_code, :api_key=> some_api_key
      end
      
      it "should report the unaffected number of api key uses remaining in the header" do
        post :some_action_with_a_300_response_code, :api_key=> some_api_key
        response.headers['Api-key-uses-remaining'].should == @uses_remaining.to_s
      end
    end
  end
  
  describe "before-filtering" do
    
    context "when no api key provided" do
      
      it "should respond with status code 401 and the expected message" do
        post :some_action_with_a_200_response_code
        response.code.should eql "401"
        response.body.should eql({:error=>"No api key supplied"}.to_json)
      end
      
    end
    
    context "when api key is not valid" do
      
      it "should respond with status code 401 and the expected message" do
        key.stub(:valid?).and_return false
        ApiKey.stub(:find_by_value).and_return key
        post :some_action_with_a_200_response_code, :api_key=>some_api_key
        response.code.should eql "401"
        response.body.should eql({:error=>"Invalid api key"}.to_json)
      end
      
    end
    
    context "when api key provided does not exist in data store" do
      
      it "should respond with status code 401 and the expected message" do
        ApiKey.stub(:find_by_value).and_return nil
        post :some_action_with_a_200_response_code, :api_key=>some_api_key
        response.code.should eql "401"
        response.body.should eql({:error=>"Invalid api key"}.to_json)
      end
      
    end
    
    context "when server raises an error" do
      
      it "should respond with status code 500 and the expected message" do
        ApiKey.should_receive(:find_by_value).and_raise StandardError
        post :some_action_with_a_200_response_code, :api_key=>some_api_key
        response.code.should eql "500"
        response.body.should eql({:error=>"Api key search failure"}.to_json)
      end
      
      it "should log the failure" do
        pending
      end
      
    end
    
    context "when existing key is properly requested" do
      
      before(:each) do
        @key_stubbed_for_after_filtering = key
        @key_stubbed_for_after_filtering.stub(:get_uses_remaining_and_increment_times_used_by_1)
        @key_stubbed_for_after_filtering.stub(:save)
      end
      
      it "should result in a response with the status and body from the inheriting controller action" do
        @key_stubbed_for_after_filtering.stub(:valid?).and_return true
        ApiKey.should_receive(:find_by_value).with(some_api_key).and_return @key_stubbed_for_after_filtering
        post :some_action_with_a_200_response_code, :api_key=>some_api_key
        response.code.should eql "200"
        response.body.should eql({:result =>"Some result for testing..."}.to_json)
      end
    end
    
  end

end
