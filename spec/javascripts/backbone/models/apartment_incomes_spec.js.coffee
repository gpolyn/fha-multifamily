describe "ApartmentIncomes", ->
	validAttrs =
		monthlyRent: 2500
		squareFeet: 2000
		units: 40
	apt1 = new TodoApp.ApartmentIncome validAttrs
	zeroBrUnits = 40
	apt1.set {units: zeroBrUnits, bedrooms: 0}, {silent: true}
	apt2 = new TodoApp.ApartmentIncome validAttrs
	oneBrUnits = 54
	apt2.set {units: oneBrUnits, bedrooms: 1}, {silent: true}
	apt3 = new TodoApp.ApartmentIncome validAttrs
	twoBrUnits = 75
	apt3.set {units: twoBrUnits, bedrooms: 2}, {silent: true}
	apt4 = new TodoApp.ApartmentIncome validAttrs
	threeBrUnits = 35
	apt4.set {units: threeBrUnits, bedrooms: 3}, {silent: true}
	apt5 = new TodoApp.ApartmentIncome validAttrs
	fourBrUnits = 66
	apt5.set {units: fourBrUnits, bedrooms: 4}, {silent: true}
	apts = [apt1, apt2, apt3, apt4, apt5]
	coll = null
	
	beforeEach ->
		coll = new TodoApp.ApartmentIncomes apts
	
	it "should be an instance of TodoApp.IncomeSources", ->
		expect(coll instanceof TodoApp.IncomeSources).toBe true
	
	describe "localStorage", ->
		it "should be an instance of Store", ->
			expect(coll.localStorage instanceof Store).toBe true
		
		it "should have a Store with the name 'apartmentIncomes'", ->
			expect(coll.localStorage.name).toEqual 'apartmentIncomes'
	

	describe "totalAnnualIncome", ->
		it "should be the sum of apartment incomes", ->
			func = (memo, inc) -> memo + validAttrs.monthlyRent * inc.get 'units'
			expected = _.reduce(apts, func, 0)
			expected *= 12
			expect(coll.totalAnnualIncome()).toEqual expected
		
		
	describe "totalSquareFeet", ->
		it "should be the sum of apartment square footages, when all provided", ->
			func = (memo, inc) -> memo + validAttrs.squareFeet * inc.get 'units'
			expected = _.reduce(apts, func, 0)
			expect(coll.totalSquareFeet()).toEqual expected
		
	describe "model", ->
		it "should be TodoApp.ApartmentIncome", ->
			expect(coll.model is TodoApp.ApartmentIncome).toBe true
		
	
	describe "unitsPerBedroomHash", ->
		it "should be as expected", ->
			expected = 
				zeroBedroomUnits: zeroBrUnits
				oneBedroomUnits: oneBrUnits
				twoBedroomUnits: twoBrUnits
				threeBedroomUnits: threeBrUnits
				fourBedroomUnits: fourBrUnits
			expect(coll.unitsPerBedroomHash()).toEqual expected