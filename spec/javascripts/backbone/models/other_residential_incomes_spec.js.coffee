describe "OtherResidentialIncomes", ->
	coll = null
	
	beforeEach ->
		coll = new TodoApp.OtherResidentialIncomes
	
	it "should be an instance of TodoApp.IncomeSources", ->
		expect(coll instanceof TodoApp.IncomeSources).toBe true
	
	describe "localStorage", ->
		it "should be an instance of Store", ->
			expect(coll.localStorage instanceof Store).toBe true
		
		it "should have a Store with the name 'otherResidentialIncomes'", ->
			expect(coll.localStorage.name).toEqual 'otherResidentialIncomes'
	
		
	describe "model", ->
		it "should be TodoApp.OtherResidentialIncome", ->
			expect(coll.model is TodoApp.OtherResidentialIncome).toBe true
		