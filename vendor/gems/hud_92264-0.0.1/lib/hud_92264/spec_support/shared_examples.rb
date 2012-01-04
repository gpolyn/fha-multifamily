shared_examples_for "Hud92264::A3::TotalRequirementsForSettlement::PartB" do
  
  let(:some_int) {1234}
  
  describe "methods not overridden, thus preserving the contract for this module" do

    after(:each) {host.method(@sym).owner.should == Hud92264::A3::TotalRequirementsForSettlement::PartB}

    it "includes #line_1_c" do
      @sym = :line_1_c
    end

    it "includes #line_3" do
      @sym = :line_3
    end

    it "includes #grant_or_loan_and_replacement_reserve_and_major_movable_equipment" do
      @sym = :grant_or_loan_and_replacement_reserve_and_major_movable_equipment
    end

    it "includes #lines_4a_plus_4b_plus_5" do
      @sym = :lines_4a_plus_4b_plus_5
    end

    it "includes #cash_investment_required" do
      @sym = :cash_investment_required
    end

    it "includes #total_estimated_cash_requirement" do
      @sym = :total_estimated_cash_requirement
    end
  end

  describe "required attributes" do

    after(:each) {@lambda.should_not raise_error NotImplementedError}

    describe "#transaction_amount_including_loan_closing_charges" do
      specify {@lambda = lambda {host.transaction_amount_including_loan_closing_charges}}
    end

    describe "#required_repairs" do
      specify {@lambda = lambda {host.required_repairs}}
    end

    describe "#initial_operating_deficit" do
      specify {@lambda = lambda {host.initial_operating_deficit}}
    end

    describe "#mortgage_amount" do
      specify {@lambda = lambda {host.mortgage_amount}}
    end

    describe "#grant_or_loan" do
      specify {@lambda = lambda {host.grant_or_loan}}
    end

    describe "#replacement_reserve" do
      specify {@lambda = lambda {host.replacement_reserve}}
    end

    describe "#major_movable_equipment" do
      specify {@lambda = lambda {host.major_movable_equipment}}
    end
  end

  describe "line_1_a" do
    it "should be an alias for transaction_amount_including_loan_closing_charges" do
      host.should_receive(:transaction_amount_including_loan_closing_charges).and_return some_int
      host.line_1_a.should == some_int
    end
  end

  describe "line_1_c" do
    it "should be an alias for line_1_a" do
      host.should_receive(:line_1_a).and_return some_int
      host.line_1_c.should == some_int
    end
  end

  describe "line_2" do
    it "should be an alias for required_repairs" do
      host.should_receive(:required_repairs).and_return some_int
      host.line_2.should == some_int
    end
  end

  describe "subtotal_lines_1c_and_2" do
    it "should be an alias for line_3" do
      host.should_receive(:line_3).and_return some_int
      host.subtotal_lines_1c_and_2.should == some_int
    end
  end

  describe "line_4_a" do
    it "should be an alias for mortgage_amount" do
      host.should_receive(:mortgage_amount).and_return some_int
      host.line_4_a.should == some_int
    end
  end

  describe "line_4_b" do
    it "should be an alias for grant_or_loan_and_replacement_reserve_and_major_movable_equipment" do
      host.should_receive(:grant_or_loan_and_replacement_reserve_and_major_movable_equipment).and_return some_int
      host.line_4_b.should == some_int
    end
  end

  describe "line_6" do
    it "should be an alias for lines_4a_plus_4b_plus_5" do
      host.should_receive(:lines_4a_plus_4b_plus_5).and_return some_int
      host.line_6.should == some_int
    end
  end

  describe "line_7" do
    it "should be an alias for cash_investment_required" do
      host.should_receive(:cash_investment_required).and_return some_int
      host.line_7.should == some_int
    end
  end

  describe "line_8" do
    it "should be an alias for initial_operating_deficit" do
      host.should_receive(:initial_operating_deficit).and_return some_int
      host.line_8.should == some_int
    end
  end

  describe "line_12" do
    it "should be an alias for total_estimated_cash_requirement" do
      host.should_receive(:total_estimated_cash_requirement).and_return some_int
      host.line_12 == some_int
    end
  end
end