shared_examples_for "Hud92013::Attachments::DevelopmentCosts" do

  after(:each) {@lambda.should_not raise_error NoMethodError}

  describe "#initial_deposit_to_reserve_fund" do
    specify {@lambda = lambda {host.initial_deposit_to_reserve_fund}}
  end

  describe "#estimate_of_repair_cost" do
    specify {@lambda = lambda {host.estimate_of_repair_cost}}
  end

  describe "#fha_inspection_fee" do
    specify {@lambda = lambda {host.fha_inspection_fee}}
  end

  describe "#financing_fee" do
    specify {@lambda = lambda {host.financing_fee}}
  end

  describe "#mortgageable_bond_costs" do
    specify {@lambda = lambda {host.mortgageable_bond_costs}}
  end

  describe "#discount" do
    specify {@lambda = lambda {host.discount}}
  end

  describe "#permanent_placement_fee" do
    specify {@lambda = lambda {host.permanent_placement_fee}}
  end

  describe "#legal_and_organizational" do
    specify {@lambda = lambda {host.legal_and_organizational}}
  end

  describe "#title_and_recording" do
    specify {@lambda = lambda {host.title_and_recording}}
  end

  describe "#fha_exam_fee" do
    specify {@lambda = lambda {host.fha_exam_fee}}
  end

  describe "#first_year_mip" do
    specify {@lambda = lambda {host.first_year_mip}}
  end

  describe "#third_party_reports" do
    specify {@lambda = lambda {host.third_party_reports}}
  end

  describe "#survey" do
    specify {@lambda = lambda {host.survey}}
  end

  describe "#other" do
    specify {@lambda = lambda {host.other}}
  end

  describe "#total_development_costs" do
    specify {@lambda = lambda {host.total_development_costs}}
  end

end