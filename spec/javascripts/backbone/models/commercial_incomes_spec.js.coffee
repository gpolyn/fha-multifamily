describe "CommercialIncomes", ->
	coll = null
	
	beforeEach ->
		coll = new TodoApp.CommercialIncomes
	
	it "should be an instance of TodoApp.IncomeSources", ->
		expect(coll instanceof TodoApp.IncomeSources).toBe true
	
	describe "localStorage", ->
		it "should be an instance of Store", ->
			expect(coll.localStorage instanceof Store).toBe true
		
		it "should have a Store with the name 'commercialIncomes'", ->
			expect(coll.localStorage.name).toEqual 'commercialIncomes'
	
		
	describe "model", ->
		it "should be TodoApp.CommercialIncome", ->
			expect(coll.model is TodoApp.CommercialIncome).toBe true
