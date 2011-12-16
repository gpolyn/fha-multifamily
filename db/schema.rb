# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111202010031) do

  create_table "api_keys", :force => true do |t|
    t.string   "value"
    t.integer  "times_used", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fha_leverage_ratio_sets", :force => true do |t|
    t.decimal  "market",             :precision => 5, :scale => 2
    t.decimal  "affordable",         :precision => 5, :scale => 2
    t.decimal  "subsidized",         :precision => 5, :scale => 2
    t.decimal  "cash_out_refinance", :precision => 5, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "high_cost_percentages", :force => true do |t|
    t.string   "city"
    t.string   "state_abbreviation"
    t.integer  "value"
    t.string   "regional_office_city"
    t.string   "regional_office_state_abbreviation"
    t.string   "cbsa_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sec207223f_mortgage_insurance_premia", :force => true do |t|
    t.decimal  "without_lihtc_annual",  :precision => 5, :scale => 2
    t.decimal  "with_lihtc_annual",     :precision => 5, :scale => 2
    t.decimal  "without_lihtc_initial", :precision => 5, :scale => 2
    t.decimal  "with_lihtc_initial",    :precision => 5, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sec223f_multifamily_acquisition_parameters_initialization_sets", :force => true do |t|
    t.decimal  "mortgage_interest_rate",                 :precision => 5, :scale => 2
    t.decimal  "financing_fee_as_percent_of_loan",       :precision => 5, :scale => 2
    t.integer  "financing_fee_in_dollars"
    t.integer  "legal_and_organizational"
    t.decimal  "title_and_recording_as_percent_of_loan", :precision => 6, :scale => 3
    t.integer  "title_and_recording_in_dollars"
    t.integer  "third_party_reports"
    t.integer  "other"
    t.integer  "survey"
    t.integer  "annual_replacement_reserve_per_unit"
    t.decimal  "exam_fee_rate",                          :precision => 5, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sec223f_multifamily_elevator_stat_limit_sets", :force => true do |t|
    t.integer  "zero_bedroom"
    t.integer  "one_bedroom"
    t.integer  "two_bedroom"
    t.integer  "three_bedroom"
    t.integer  "four_bedroom"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sec223f_multifamily_non_elevator_stat_limit_sets", :force => true do |t|
    t.integer  "zero_bedroom"
    t.integer  "one_bedroom"
    t.integer  "two_bedroom"
    t.integer  "three_bedroom"
    t.integer  "four_bedroom"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sec223f_occupancy_constraint_sets", :force => true do |t|
    t.decimal  "minimum_residential_occupancy_percent",             :precision => 5, :scale => 2
    t.decimal  "maximum_commercial_occupancy_percent",              :precision => 5, :scale => 2
    t.decimal  "maximum_market_rate_residential_occupancy_percent", :precision => 5, :scale => 2
    t.decimal  "maximum_affordable_residential_occupancy_percent",  :precision => 5, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
