describe "ResidentialParkingIncomes", ->
	coll = null
	
	beforeEach ->
		coll = new TodoApp.ResidentialParkingIncomes
	
	it "should be an instance of TodoApp.IncomeSources", ->
		expect(coll instanceof TodoApp.IncomeSources).toBe true
	
	describe "localStorage", ->
		it "should be an instance of Store", ->
			expect(coll.localStorage instanceof Store).toBe true
		
		it "should have a Store with the name 'residentialParkingIncomes'", ->
			expect(coll.localStorage.name).toEqual 'residentialParkingIncomes'
	
		
	describe "model", ->
		it "should be TodoApp.ResidentialParkingIncome", ->
			expect(coll.model is TodoApp.ResidentialParkingIncome).toBe true
