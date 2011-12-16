describe "OperatingExpense", ->
	opex = null
	
	beforeEach ->
		opex = new TodoApp.OperatingExpense
	
	describe "localStorage", ->
		it "should be an instance of Store", ->
			expect(opex.localStorage instanceof Store).toBe true
		
		it "should have a Store with the name 'operatingExpense'", ->
			expect(opex.localStorage.name).toEqual 'operatingExpense'
	

	describe "validation", ->
		eventSpy = null
		errorMsg = null

		beforeEach ->
			opex = new TodoApp.OperatingExpense
			eventSpy = sinon.spy()
			opex.bind("error", eventSpy)

		afterEach ->
			# aptIncome.save validAttrs
			expect(eventSpy.calledOnce).toBeTruthy()
			expect(eventSpy.calledWith(opex, [errorMsg])).toBeTruthy()
			
		describe "total when opex is being expressed as dollar amount", ->
			it "should be greater than 0", ->
				errorMsg = "Total operating expense must be greater than 0"
				opex.set {total: -0.01}
			
		
		describe "total when opex is being expressed as a percentage", ->
			it "should be greater than 0", ->
				errorMsg = "Total operating expense must be greater than 0"
				opex.set {total: -0.01, totalIsPercentOfEffectiveGrossIncome: true}
			
			it "should be less than or equal to 100", ->
				errorMsg = "Total operating expense percent must be less than 100"
				opex.set {total: 100.01, totalIsPercentOfEffectiveGrossIncome: true}
			
		
	describe "toJSONWithoutIDParam", ->
		it "should have expected params", ->
			expectedtotal = 3000
			expectedIsPercent = false
			attrs = {total: expectedtotal, totalIsPercentOfEffectiveGrossIncome: expectedIsPercent}
			_.extend attrs, {id: 123444}
			opex.set attrs, {silent: true}
			expectedHash =
				total: expectedtotal
				totalIsPercentOfEffectiveGrossIncome: expectedIsPercent
			expect(opex.toJSONWithoutIDParam()).toEqual expectedHash
		
