class TodoApp.MetropolitanArea extends TodoApp.SingletonLikeModel
	
	@list: ->
		ret = new Array()
		ret.push "no waiver"
		ret.push "standard waiver"
		ret.push "maximum waiver"
		ret.push "Albany, NY"
		ret.push "Albuquerque, NM"
		ret.push "Anchorage, AK"
		ret.push "Atlanta, GA"
		ret.push "Baltimore, MD"
		ret.push "Bangor, ME (Portland)"
		ret.push "Birmingham, AL"
		ret.push "Boise, ID"
		ret.push "Boston, MA"
		ret.push "Buffalo, NY"
		ret.push "Burlington, VT"
		ret.push "Camden, NJ (Trenton)"
		ret.push "Casper, WY"
		ret.push "Charleston, WV"
		ret.push "Chicago, IL"
		ret.push "Cincinnati, OH"
		ret.push "Cleveland, OH"
		ret.push "Columbia, SC"
		ret.push "Columbus, OH"
		ret.push "Dallas, TX"
		ret.push "Denver, CO"
		ret.push "Des Moines, IA"
		ret.push "Detroit, MI"
		ret.push "Fargo, ND"
		ret.push "Fort Worth, TX"
		ret.push "Grand Rapids, MI"
		ret.push "Greensboro, NC"
		ret.push "Hartford, CT"
		ret.push "Helena, MT"
		ret.push "Honolulu, HI"
		ret.push "Houston, TX"
		ret.push "Indianapolis, IN"
		ret.push "Jackson, MS"
		ret.push "Jacksonville, FL"
		ret.push "Kansas City, KS"
		ret.push "Knoxville, TN"
		ret.push "Las Vegas, NV"
		ret.push "Little Rock, AR"
		ret.push "Los Angeles, CA"
		ret.push "Lubbock, TX"
		ret.push "Louisville, KY"
		ret.push "Manchester, NH"
		ret.push "Memphis, TN"
		ret.push "Miami, FL"
		ret.push "Milwaukee, WI"
		ret.push "Minneapolis, MN"
		ret.push "Nashville, TN"
		ret.push "New Orleans, LA"
		ret.push "New York, NY"
		ret.push "Newark, NJ"
		ret.push "Oklahoma City, OK"
		ret.push "Omaha, NE"
		ret.push "Philadelphia, PA"
		ret.push "Phoenix, AZ"
		ret.push "Pittsburgh, PA"
		ret.push "Portland, OR"
		ret.push "Providence, RI"
		ret.push "Richmond, VA"
		ret.push "Sacramento, CA"
		ret.push "Salt Lake City, UT"
		ret.push "San Antonio, TX"
		ret.push "San Diego, CA"
		ret.push "San Francisco, CA"
		ret.push "San Juan, PR (Key West)"
		ret.push "Santa Ana, CA (L.A.)"
		ret.push "Seattle, WA"
		ret.push "Shreveport, LA"
		ret.push "Sioux Falls, SD"
		ret.push "Spokane, WA"
		ret.push "Springfield, IL"
		ret.push "St. Louis, MO"
		ret.push "Tampa, FL"
		ret.push "Topeka, KS"
		ret.push "Tulsa, OK"
		ret.push "US Virgin Islands"
		ret.push "Washington, DC"
		ret.push "Wilmington, DE"
		ret
	
	@localStorage: -> new Store "metropolitanArea"
	
	localStorage: @localStorage()

	toJSON: ->
		value: @get 'value'
