describe "ParkingIncome", ->
	parkingIncome = null
	
	it "should be an instance of TodoApp.IncomeSource", ->
		expect(new TodoApp.ParkingIncome instanceof TodoApp.IncomeSource).toBe true
	

	describe "totalSquareFeet", ->

		beforeEach ->
			parkingIncome = new TodoApp.ParkingIncome

		describe "value when valid square feet attribute present", ->
			it "should be expected value", ->
				parkingIncome.set squareFeet: 2000, {silent: true}
				expect(parkingIncome.totalSquareFeet()).toEqual(2000)

		describe "value when square feet attribute is missing or invalid", ->	
			afterEach ->
				expect(parkingIncome.totalSquareFeet()).toEqual(null)

			it "should be null when no squareFeet", ->
				parkingIncome.set squareFeet: null, {silent: true}

			it "should be null when squareFeet invalid", ->
				parkingIncome.set squareFeet: 0, {silent: true}
	
	describe "grossAnnualIncome", ->
		spaces = 40
		monthlyFee = 1000
			
		beforeEach ->
			parkingIncome = new TodoApp.ParkingIncome {spaces: spaces, monthlyFee: monthlyFee}

		describe "value when valid monthly fee and spaces attributes present", ->
			it "should be expected value", ->
				expected = monthlyFee * 12 * spaces
				expect(parkingIncome.grossAnnualIncome()).toEqual(expected)
			
		
		describe "value when monthly fee attribute is missing or invalid", ->	
			afterEach ->
				expect(parkingIncome.grossAnnualIncome()).toEqual(null)

			it "should be null when no monthly fee", ->
				parkingIncome.set monthlyFee: null, {silent: true}

			it "should be null when monthly fee invalid", ->
				parkingIncome.set monthlyFee: -1, {silent: true}
			
		
		describe "value when spaces attribute is missing or invalid", ->	
			afterEach ->
				expect(parkingIncome.grossAnnualIncome()).toEqual(null)

			it "should be null when no spaces", ->
				parkingIncome.set spaces: null, {silent: true}

			it "should be null when spaces invalid", ->
				parkingIncome.set spaces: 0, {silent: true}
			
	
		describe "validation", ->
			somePositiveNumber = 1
			eventSpy = null
			validAttrs = null
			errorMsg = null

			beforeEach ->
				validAttrs =
					outdoorOrIndoor: "outdoor"
					monthlyFee: somePositiveNumber
					spaces: somePositiveNumber
				parkingIncome = new TodoApp.ParkingIncome
				eventSpy = sinon.spy()
				parkingIncome.bind("error", eventSpy)

			afterEach ->
				parkingIncome.save validAttrs
				expect(eventSpy.calledOnce).toBeTruthy()
				expect(eventSpy.calledWith(parkingIncome, [errorMsg])).toBeTruthy()

			describe "monthlyFee", ->
				beforeEach ->
					errorMsg = "Monthly parking fee be greater than or equal to $0"

				it "must be a positive number", ->
					validAttrs.monthlyFee = -1

				it "cannot be blank", ->
					validAttrs.monthlyFee = null

			describe "outdoorOrIndoor", ->
				beforeEach ->
					errorMsg = "Parking must be either outdoor or indoor"

				it "must be in {'outdoor', 'indoor'}", ->
					validAttrs.outdoorOrIndoor = "smoke"

				it "cannot be blank", ->
					validAttrs.outdoorOrIndoor = null

			describe "spaces", ->
				beforeEach ->
					errorMsg = "Parking spaces must be an integer greater than 0"

				it "must be an integer", ->
					validAttrs.spaces = 1.1

				it "must be greater than 0", ->
					validAttrs.spaces = 0

				it "cannot be blank", ->
					validAttrs.spaces = null

			describe "squareFeet", ->

				it "must be a number greater than 0, when provided", ->
					errorMsg = "If provided, parking square feet must be greater than 0"
					validAttrs.squareFeet = 0
				
			

