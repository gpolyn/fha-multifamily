describe "CommercialIncome", ->
	commIncome = null
	
	it "should be an instance of TodoApp.IncomeSource", ->
		expect(new TodoApp.CommercialIncome() instanceof TodoApp.IncomeSource).toBe true
	
	describe "totalSquareFeet", ->

		beforeEach ->
			commIncome = new TodoApp.CommercialIncome
		
		describe "value when valid square feet attribute present", ->
			it "should be expected value", ->
				commIncome.set squareFeet: 2000, {silent: true}
				expect(commIncome.totalSquareFeet()).toEqual(2000)
		
		describe "value when square feet attribute is missing or invalid", ->	
			afterEach ->
				expect(commIncome.totalSquareFeet()).toEqual(null)
			
			it "should be null when no squareFeet", ->
				commIncome.set squareFeet: null, {silent: true}
		
			it "should be null when squareFeet invalid", ->
				commIncome.set squareFeet: -1, {silent: true}
	
	describe "grossAnnualIncome", ->

		beforeEach ->
			commIncome = new TodoApp.CommercialIncome

		describe "value when valid monthly rent attribute present", ->
			it "should be expected value", ->
				commIncome.set monthlyRent: 2000, {silent: true}
				expected = 2000 * 12
				expect(commIncome.grossAnnualIncome()).toEqual(expected)

		describe "value when monthly rent attribute is missing or invalid", ->	
			afterEach ->
				expect(commIncome.grossAnnualIncome()).toEqual(null)

			it "should be null when no monthlyRent", ->
				commIncome.set monthlyRent: null, {silent: true}

			it "should be null when monthlyRent invalid", ->
				commIncome.set monthlyRent: -1, {silent: true}
			
	describe "validation", ->
		somePositiveNumber = 1
		eventSpy = null
		validAttrs = null
		errorMsg = null

		beforeEach ->
			validAttrs =
				monthlyRent: somePositiveNumber
				squareFeet: somePositiveNumber
			commIncome = new TodoApp.CommercialIncome
			eventSpy = sinon.spy()
			commIncome.bind("error", eventSpy)

		afterEach ->
			commIncome.save validAttrs
			expect(eventSpy.calledOnce).toBeTruthy()
			expect(eventSpy.calledWith(commIncome, [errorMsg])).toBeTruthy()

		describe "monthlyRent", ->
			beforeEach ->
				errorMsg = "Monthly commercial rent must be greater than $0"
			
			it "must be a number greater than 0", ->
				validAttrs.monthlyRent = 0
			
			it "cannot be blank", ->
				validAttrs.monthlyRent = null
			
			
		describe "squareFeet", ->

			it "must be a number greater than 0, when provided", ->
				errorMsg = "If provided, commercial square feet must be greater than 0"
				validAttrs.squareFeet = 0
			
		
