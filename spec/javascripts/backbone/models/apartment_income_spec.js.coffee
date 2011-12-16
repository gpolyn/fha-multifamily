describe "ApartmentIncome", ->
	aptIncome = null
	
	it "should be an instance of TodoApp.IncomeSource", ->
		expect(new TodoApp.ApartmentIncome() instanceof TodoApp.IncomeSource).toBe true
	
	
	describe "saving valid instance", ->
		xit "should do something expected", ->
			# myAPI = 
				# create: ->
					# null
				
			# mock = sinon.mock(myAPI)
			# mock.expects("create").once()
			storageMock = sinon.spy()#jasmine.createSpy('storageMock')
			# foo = {
			  # create: ->
				# false
			# }
			# // actual foo.not will not be called, execution stops
			# spyOn(foo, 'not')
			# storage = 
				# create: ->
					# true
				
			collection = {localStorage: storageMock}

			# spyOn(collection, 'localStorage')
			validAttrs =
				bedrooms: 3
				monthlyRent: 2500
				units: 40
			aptIncome = new TodoApp.ApartmentIncome #collection: collection
			aptIncome.collection = collection
			aptIncome.save validAttrs
			# mock.verify()
			# assert()
			expect(storageMock.called).toBe true
	
	describe "totalSquareFeet", ->
		units = 100
		squareFeet = 2000
		
		beforeEach ->
			aptIncome = new TodoApp.ApartmentIncome units: units, squareFeet: squareFeet
		
		describe "value when valid square feet and units present", ->
			it "should be expected product", ->
				expected = units * squareFeet
				expect(aptIncome.totalSquareFeet()).toEqual(expected)
		
		describe "value when required elements are missing or invalid", ->	
			afterEach ->
				expect(aptIncome.totalSquareFeet()).toEqual(null)
			
			it "should be null when no squareFeet", ->
				aptIncome.set squareFeet: null, {silent: true}
		
			it "should be null when no units", ->
				aptIncome.set units: null, {silent: true}
		
			it "should be null when units invalid", ->
				aptIncome.set units: 0, {silent: true}
		
			it "should be null when squareFeet invalid", ->
				aptIncome.set squareFeet: 0, {silent: true}
			
			
	
	describe "totalAnnualUnitRent", ->
		units = 100
		monthlyRent = 2000
		
		beforeEach ->
			aptIncome = new TodoApp.ApartmentIncome units: units, monthlyRent: monthlyRent
		
		describe "value when valid monthly rent and units present", ->
			it "should be expected product", ->
				expected = 12 * units * monthlyRent
				expect(aptIncome.totalAnnualUnitRent()).toEqual(expected)
		
		describe "value when required elements are missing or invalid", ->	
			afterEach ->
				expect(aptIncome.totalAnnualUnitRent()).toEqual(null)
			
			it "should be null when no monthlyRent", ->
				aptIncome.set monthlyRent: null, {silent: true}
		
			it "should be null when no units", ->
				aptIncome.set units: null, {silent: true}
		
			it "should be null when units invalid", ->
				aptIncome.set units: 0, {silent: true}
		
			it "should be null when monthly rent invalid", ->
				aptIncome.set monthlyRent: -1, {silent: true}
			
			

	describe "validation", ->
		somePositiveNumber = 1
		eventSpy = null
		validAttrs = null
		errorMsg = null

		beforeEach ->
			validAttrs =
				bedrooms: somePositiveNumber
				monthlyRent: somePositiveNumber
				units: somePositiveNumber
			aptIncome = new TodoApp.ApartmentIncome
			eventSpy = sinon.spy()
			aptIncome.bind("error", eventSpy)

		afterEach ->
			aptIncome.save validAttrs
			expect(eventSpy.calledOnce).toBeTruthy()
			expect(eventSpy.calledWith(aptIncome, [errorMsg])).toBeTruthy()

		describe "monthlyRent", ->
			beforeEach ->
				errorMsg = "Monthly apartment rent must be greater than $0"

			it "must be a number greater than 0", ->
				console.log("testing: must be a number greater than 0")
				validAttrs.monthlyRent = 0

			it "cannot be blank", ->
				console.log("testing: cannot be blank")
				validAttrs.monthlyRent = null

		describe "bedrooms", ->
			beforeEach ->
				errorMsg = "Bedrooms must be one of 0, 1, 2, 3 or 4"

			it "must be in {0, 1, 2, 3, 4}", ->
				validAttrs.bedrooms = 5

			it "cannot be blank", ->
				validAttrs.bedrooms = null

		describe "units", ->
			beforeEach ->
				errorMsg = "Apartment units must be an integer greater than 0"

			it "must be an integer", ->
				validAttrs.units = 1.1

			it "must be greater than 0", ->
				validAttrs.units = 0

			it "cannot be blank", ->
				validAttrs.units = null

		describe "squareFeet", ->

			it "must be a number greater than 0, when provided", ->
				errorMsg = "If provided, apartment square feet must be greater than 0"
				validAttrs.squareFeet = 0
		

  