class Api::Beta1::DocumentationController < ApplicationController
  
  respond_to :html
  
  def catch_all
    flash[:notice] = "You selected a non-existent path."
    redirect_to :action => :home
  end
  
  def home
    # no-op!
  end
  
  def fha_overview
    # no-op
  end
  
  def sec223f_refinance
    @hcps = metropolitan_areas
  end
  
  def sec223f_acquisition
    @hcps = metropolitan_areas
  end
  
  def sec223f
    @hcps = metropolitan_areas
  end
  
  private
  
  def metropolitan_areas
    ["Albany, NY",
    "Albuquerque, NM",
    "Anchorage, AK",
    "Atlanta, GA",
    "Baltimore, MD",
    "Bangor, ME",
    "Birmingham, AL",
    "Boise, ID",
    "Boston, MA",
    "Buffalo, NY",
    "Burlington, VT",
    "Camden, NJ",
    "Casper, WY",
    "Charleston, WV",
    "Chicago, IL",
    "Cincinnati, OH",
    "Cleveland, OH",
    "Columbia, SC",
    "Columbus, OH",
    "Dallas, TX",
    "Denver, CO",
    "Des Moines, IA",
    "Detroit, MI",
    "Fargo, ND",
    "Fort Worth, TX",
    "Grand Rapids, MI",
    "Greensboro, NC",
    "Hartford, CT",
    "Helena, MT",
    "Honolulu, HI",
    "Houston, TX",
    "Indianapolis, IN",
    "Jackson, MS",
    "Jacksonville, FL",
    "Kansas City, KS",
    "Knoxville, TN",
    "Las Vegas, NV",
    "Little Rock, AR",
    "Los Angeles, CA",
    "Louisville, KY",
    "Lubbock, TX",
    "Manchester, NH",
    "Memphis, TN",
    "Miami, FL",
    "Milwaukee, WI",
    "Minneapolis, MN",
    "Nashville, TN",
    "New Orleans, LA",
    "New York, NY",
    "Newark, NJ",
    "Oklahoma City, OK",
    "Omaha, NE",
    "Philadelphia, PA",
    "Phoenix, AZ",
    "Pittsburgh, PA",
    "Portland, OR",
    "Providence, RI",
    "Richmond, VA",
    "Sacramento, CA",
    "Salt Lake City, UT",
    "San Antonio, TX",
    "San Diego, CA",
    "San Francisco, CA",
    "San Juan, PR",
    "Santa Ana, CA",
    "Seattle, WA",
    "Shreveport, LA",
    "Sioux Falls, SD",
    "Spokane, WA",
    "Springfield, IL",
    "St. Louis, MO",
    "Tampa, FL",
    "Topeka, KS",
    "Tulsa, OK",
    "US Virgin Islands, US Virgin Islands",
    "Washington, DC",
    "Wilmington, DE"]
  end
end