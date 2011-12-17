# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

costs = {:mortgage_interest_rate=>4.5, :financing_fee_as_percent_of_loan=>2.5, :financing_fee_in_dollars=>100_000,
         :legal_and_organizational=>15_000, :title_and_recording_as_percent_of_loan=> 0.005, :exam_fee_rate=>0.3,
         :third_party_reports=>15_00, :survey=>8_500, :annual_replacement_reserve_per_unit=>250}
Sec223fMultifamilyAcquisitionParametersInitializationSet.create!(costs)

Sec223fMultifamilyElevatorStatLimitSet.create!(:zero_bedroom=>53171,:one_bedroom=>59551,:two_bedroom=>73022,
                                               :three_bedroom=>91546, :four_bedroom=>103410)
Sec223fMultifamilyNonElevatorStatLimitSet.create!(:zero_bedroom=>46079,:one_bedroom=>51043,:two_bedroom=>60969,
                                                  :three_bedroom =>75149, :four_bedroom=>85077)
FhaLeverageRatioSet.create!(:subsidized=> 87, :affordable => 85, :market=>83.3, :cash_out_refinance=>80)
attrs = {:minimum_residential_occupancy_percent=>85, :maximum_commercial_occupancy_percent=>80,
         :maximum_market_rate_residential_occupancy_percent=>93, 
         :maximum_affordable_residential_occupancy_percent=>95}
Sec223fOccupancyConstraintSet.create! attrs

# http://www.gpo.gov/fdsys/pkg/FR-2011-07-11/pdf/2011-17233.pdf
Sec207223fMortgageInsurancePremium.create!(:without_lihtc_annual=>0.45, :with_lihtc_annual=>0.45,
                                           :without_lihtc_initial=>1, :with_lihtc_initial=>1)

require 'csv'

base_city_hcps = File.expand_path(File.join(Rails.root, 'db/base_city_hcps.csv'))

 CSV.open(base_city_hcps, "r") do |row| 
     HighCostPercentage.create!(:city => row[0], 
                                :state_abbreviation => row[1],
                                :value => row[4],
                                :regional_office_city=>row[2],
                                :regional_office_state_abbreviation =>row[3],
                                :cbsa_code =>row[5])
 end