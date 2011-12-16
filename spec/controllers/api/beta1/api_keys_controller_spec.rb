require 'spec_helper'

describe Api::Beta1::ApiKeysController, "#new" do
  describe "route", :type=>:routing do
    it "should be recognized" do
      assert_routing({:path=>"api/beta1/api_keys/new", :method =>:get}, 
                     {:controller=>"api/beta1/api_keys", :action =>"new"})
    end
  end
  
  describe "things it does" do
    it "should do at least one basic thing..." do
      pending
    end
  end
end

describe Api::Beta1::ApiKeysController, "#show" do
  describe "route", :type=>:routing do
    it "should be recognized" do
      some_key = "ef56sjiue8uu2"
      assert_routing({:path=>"api/beta1/api_keys/#{some_key}", :method =>:get}, 
                     {:controller=>"api/beta1/api_keys", :action =>"show", :id=>some_key})
    end
  end
  
  describe "things it does" do
    it "should do at least one basic thing..." do
      pending
    end
  end
end

describe Api::Beta1::ApiKeysController, "#create" do
  
  describe "route", :type=>:routing do
    it "should be recognized" do
      assert_routing({:path=>"api/beta1/api_keys", :method =>:post}, 
                     {:controller=>"api/beta1/api_keys", :action =>"create"})
    end
  end
  
  context "when verify_recaptcha passes" do
    
    before(:each) {@controller.should_receive(:verify_recaptcha).and_return true}
    
    context "when key is successfully created" do
      
      it "should redirect to show, whose url includes the newly created key" do
        expect{ post :create }.to change{ApiKey.count}.by(1)
        key_value = ApiKey.last.value
        response.should redirect_to(:action=>"show", :id=>key_value)
      end
      
    end
    
    context "when key is not successfully created" do
      
      let(:key){mock_model(ApiKey).as_null_object}
      
      before(:each) do
        ApiKey.stub(:new).and_return key
        key.stub(:save).and_return false
        post :create
      end
      
      it "should redirect to new" do
        response.should redirect_to(:action=>"new")
      end
      
      it "should have expected error flash message" do
        expected = "You may not be a machine, but we failed on your key creation -- please try again later"
        flash[:error].should eq expected
      end
    end
  end
  
  context "when verify_recaptcha fails" do
    
    before(:each) do
      @controller.should_receive(:verify_recaptcha).and_return false
      post :create
    end
    
    it "should redirect to new" do
      response.should redirect_to(:action=>"new")
    end
    
    it "should have failure flash error message" do
      expected = "You failed captcha -- maybe you're a machine."
      flash[:error].should eq expected
    end
  end
end
