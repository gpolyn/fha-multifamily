describe "CommercialParkingIncomes", ->
	coll = null
	
	beforeEach ->
		coll = new TodoApp.CommercialParkingIncomes
	
	it "should be an instance of TodoApp.IncomeSources", ->
		expect(coll instanceof TodoApp.IncomeSources).toBe true
	
	describe "localStorage", ->
		it "should be an instance of Store", ->
			expect(coll.localStorage instanceof Store).toBe true
		
		it "should have a Store with the name 'commercialParkingIncomes'", ->
			expect(coll.localStorage.name).toEqual 'commercialParkingIncomes'
	
		
	describe "model", ->
		it "should be TodoApp.CommercialParkingIncome", ->
			expect(coll.model is TodoApp.CommercialParkingIncome).toBe true
