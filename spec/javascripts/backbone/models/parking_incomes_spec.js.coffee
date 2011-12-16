describe "ParkingIncomes", ->
	coll = null
	somePositiveNumber = 1
	squareFeet = 1000
	validOutdoorParkingAttrs =
		outdoorOrIndoor: "outdoor"
		monthlyFee: somePositiveNumber
		spaces: somePositiveNumber
		squareFeet: squareFeet
	validIndoorParkingAttrs = _.clone(validOutdoorParkingAttrs)
	validIndoorParkingAttrs.outdoorOrIndoor = "indoor"
	indoorPking1 = new TodoApp.ParkingIncome validIndoorParkingAttrs
	indoorPking2 = new TodoApp.ParkingIncome validIndoorParkingAttrs
	outdoorPking1 = new TodoApp.ParkingIncome validOutdoorParkingAttrs
	outdoorPking2 = new TodoApp.ParkingIncome validOutdoorParkingAttrs
	outdoorPking3 = new TodoApp.ParkingIncome validOutdoorParkingAttrs
	arr = [indoorPking1, outdoorPking3, indoorPking2, outdoorPking2, outdoorPking1]
	
	beforeEach ->
		coll = new TodoApp.ParkingIncomes arr
	
	it "should be an instance of TodoApp.IncomeSources", ->
		expect(coll instanceof TodoApp.IncomeSources).toBe true
	
	describe "totalOutdoorSquareFeet", ->
		it "should be the expected sum", ->
			expected = validOutdoorParkingAttrs.squareFeet * 3
			expect(coll.totalOutdoorSquareFeet()).toEqual expected
		
	
	describe "totalIndoorSquareFeet", ->
		it "should be the expected sum", ->
			expected = validIndoorParkingAttrs.squareFeet * 2
			expect(coll.totalIndoorSquareFeet()).toEqual expected
		

