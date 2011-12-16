describe "OperatingIncome", ->
	operatingIncome = null
	commercialIncomes = null
	commercialParkingIncomes = null
	apartmentIncomes = null
	otherResidentialIncomes = null
	residentialParkingIncomes = null
	commercialIncomesStub = null
	commercialParkingIncomesStub = null
	otherResidentialIncomesStub = null
	apartmentIncomesStub = null
	residentialParkingIncomesStub = null
	operatingIncomesStub = null
	
	beforeEach ->
		commercialIncomesStub = sinon.stub(window.TodoApp, "CommercialIncomes")
		commercialIncomes = new Backbone.Collection
		commercialIncomes.totalAnnualIncome = -> 2000
		commercialIncomes.fetch = -> # no op
		commercialIncomes.isEmpty = -> false
		commercialIncomes.allSquareFootageIsProvided = -> true
		commercialIncomes.totalSquareFeet = -> 2908
		commercialIncomesStub.returns commercialIncomes

		commercialParkingIncomesStub = sinon.stub(window.TodoApp, "CommercialParkingIncomes")
		commercialParkingIncomes = new Backbone.Collection
		commercialParkingIncomes.totalAnnualIncome = -> 3000
		commercialParkingIncomes.fetch = -> # no op
		commercialParkingIncomes.isEmpty = -> false
		commercialParkingIncomes.allSquareFootageIsProvided = -> false
		commercialParkingIncomes.totalSquareFeet = -> 2040
		commercialParkingIncomesStub.returns commercialParkingIncomes
		
		otherResidentialIncomesStub = sinon.stub(window.TodoApp, "OtherResidentialIncomes")
		otherResidentialIncomes = new Backbone.Collection
		otherResidentialIncomes.totalAnnualIncome = -> 1000
		otherResidentialIncomes.fetch = -> # no op
		otherResidentialIncomes.allSquareFootageIsProvided = -> false
		otherResidentialIncomes.totalSquareFeet = -> 200
		otherResidentialIncomes.isEmpty = -> false
		otherResidentialIncomesStub.returns otherResidentialIncomes
		
		apartmentIncomesStub = sinon.stub(window.TodoApp, "ApartmentIncomes")
		apartmentIncomes = new Backbone.Collection
		apartmentIncomes.totalAnnualIncome = -> 4000
		apartmentIncomes.fetch = -> # no op
		apartmentIncomes.unitsPerBedroomHash = ->
			hash =
				zeroBedroomUnits: 20
				oneBedroomUnits: 21
				twoBedroomUnits: 25
				threeBedroomUnits: 54
				fourBedroomUnits: 89
		apartmentIncomes.allSquareFootageIsProvided = -> true
		apartmentIncomes.totalSquareFeet = -> 20000
		apartmentIncomes.isEmpty = -> false
		apartmentIncomesStub.returns apartmentIncomes
		
		residentialParkingIncomesStub = sinon.stub(window.TodoApp, "ResidentialParkingIncomes")
		residentialParkingIncomes = new Backbone.Collection
		residentialParkingIncomes.totalAnnualIncome = -> 5000
		residentialParkingIncomes.fetch = -> # no op
		residentialParkingIncomes.allSquareFootageIsProvided = -> true
		residentialParkingIncomes.totalSquareFeet = -> 908
		residentialParkingIncomes.isEmpty = -> false
		residentialParkingIncomesStub.returns residentialParkingIncomes
		operatingIncome = new TodoApp.OperatingIncome
	
	afterEach ->
		commercialParkingIncomesStub.restore()
		commercialIncomesStub.restore()
		residentialParkingIncomesStub.restore()
		otherResidentialIncomesStub.restore()
		apartmentIncomesStub.restore()
	
	describe "localStorage", ->
		it "should be an instance of Store", ->
			expect(operatingIncome.localStorage instanceof Store).toBe true

		it "should have a Store with the name 'operatingIncome'", ->
			expect(operatingIncome.localStorage.name).toEqual 'operatingIncome'
		
	
	describe "change", ->
		eventSpy = null

		beforeEach ->
			eventSpy = sinon.spy()
			operatingIncome.bind("change", eventSpy)
			operatingIncomesStub = sinon.stub(operatingIncome, "validate")
			operatingIncomesStub.returns "not undefined"
		
		afterEach ->
			expect(eventSpy.calledOnce).toBeTruthy()
			operatingIncomesStub.restore()
		
		describe "when component collection involved is CommercialParkingIncomes", ->
			it "should fire, when the collection changes", ->
				commercialParkingIncomes.trigger "change"
			
			it "should fire, when the collection adds", ->
				commercialParkingIncomes.trigger "add"
			
			it "should fire, when the collection removes", ->
				commercialParkingIncomes.trigger "remove"
		
		describe "when component collection involved is ResidentialParkingIncomes", ->
			it "should fire, when the collection changes", ->
				residentialParkingIncomes.trigger "change"

			it "should fire, when the collection adds", ->
				residentialParkingIncomes.trigger "add"

			it "should fire, when the collection removes", ->
				residentialParkingIncomes.trigger "remove"
	
		describe "when component collection involved is CommercialIncomes", ->
			it "should fire, when the collection changes", ->
				commercialIncomes.trigger "change"
			
			it "should fire, when the collection adds", ->
				commercialIncomes.trigger "add"
			
			it "should fire, when the collection removes", ->
				commercialIncomes.trigger "remove"
			
		
		describe "when component collection involved is ApartmentIncomes", ->
			it "should fire, when the collection changes", ->
				apartmentIncomes.trigger "change"

			it "should fire, when the collection adds", ->
				apartmentIncomes.trigger "add"

			it "should fire, when the collection removes", ->
				apartmentIncomes.trigger "remove"
		
		describe "when component collection involved is OtherResidentialIncomes", ->
			it "should fire, when the collection changes", ->
				otherResidentialIncomes.trigger "change"

			it "should fire, when the collection adds", ->
				otherResidentialIncomes.trigger "add"

			it "should fire, when the collection removes", ->
				otherResidentialIncomes.trigger "remove"
			
		
	describe "grossCommercialIncome", ->
		it "should be the sum of commercial and commercial parking total incomes", ->
			expected = commercialParkingIncomes.totalAnnualIncome() 
			expected += commercialIncomes.totalAnnualIncome()
			expect(operatingIncome.grossCommercialIncome()).toEqual expected
		
	
	describe "grossResidentialIncome", ->
		it "should be the sum of apartment, other and residential parking incomes", ->
			expected = apartmentIncomes.totalAnnualIncome()
			expected += otherResidentialIncomes.totalAnnualIncome()
			expected += residentialParkingIncomes.totalAnnualIncome()
			expect(operatingIncome.grossResidentialIncome()).toEqual expected
		
	
	describe "effectiveGrossIncome", ->
		commercialEGIStub = null
		residentialEGIStub = null
		
		beforeEach ->
			commercialEGIStub = sinon.stub(operatingIncome, "effectiveGrossCommercialIncome")
			residentialEGIStub = sinon.stub(operatingIncome, "effectiveGrossResidentialIncome")
			
		afterEach ->
			commercialEGIStub.restore()
			residentialEGIStub.restore()
			
		it "should be the sum of commercial, residential egi, when both are present", ->
			val1 = 345
			val2 = 245
			residentialEGIStub.returns val1
			commercialEGIStub.returns val2
			expected = val1 + val2
			expect(operatingIncome.effectiveGrossIncome()).toEqual expected
			
		it "should be null when no commercial egi", ->
			residentialEGIStub.returns 345
			expect(operatingIncome.effectiveGrossIncome()).toBe null
		
		it "should be null when no residential egi", ->
			commercialEGIStub.returns 345
			expect(operatingIncome.effectiveGrossIncome()).toBe null
		
	describe "effectiveGrossResidentialIncome", ->
		beforeEach ->
			operatingIncomesStub = sinon.stub(operatingIncome, "grossResidentialIncome")
		
		afterEach ->
			operatingIncomesStub.restore()
		
		it "should be null when no gross residential income", ->
			operatingIncome.set {residentialOccupancyPercent: 86.7}, {silent: true}
			operatingIncomesStub.returns null
			expect(operatingIncome.effectiveGrossResidentialIncome()).toEqual null
		
		it "should be null when no residential occupancy percent", ->
			operatingIncomesStub.returns 100000
			expect(operatingIncome.has "residentialOccupancyPercent").toBe false
			expect(operatingIncome.effectiveGrossResidentialIncome()).toEqual null
			
		it "should be expected product when residential occupancy & gross income present", ->
			pct = 86.7
			operatingIncome.set {residentialOccupancyPercent: pct}, {silent: true}
			grossIncome = 20000
			operatingIncomesStub.returns grossIncome
			expected = pct/100 * grossIncome
			expect(operatingIncome.effectiveGrossResidentialIncome()).toBeCloseTo expected
		
	describe "effectiveGrossCommercialIncome", ->
		beforeEach ->
			operatingIncomesStub = sinon.stub(operatingIncome, "grossCommercialIncome")

		afterEach ->
			operatingIncomesStub.restore()

		it "should be null when no gross commercial income", ->
			operatingIncome.set {commercialOccupancyPercent: 76.7}, {silent: true}
			operatingIncomesStub.returns null
			expect(operatingIncome.effectiveGrossCommercialIncome()).toEqual null

		it "should be null when no commercial occupancy percent", ->
			operatingIncomesStub.returns 100000
			expect(operatingIncome.has "commercialOccupancyPercent").toBe false
			expect(operatingIncome.effectiveGrossCommercialIncome()).toEqual null

		it "should be expected product when residential occupancy & gross income present", ->
			pct = 86.7
			operatingIncome.set {commercialOccupancyPercent: pct}, {silent: true}
			grossIncome = 20000
			operatingIncomesStub.returns grossIncome
			expected = pct/100 * grossIncome
			expect(operatingIncome.effectiveGrossCommercialIncome()).toBeCloseTo expected
	
	describe "toJSON", ->
			
		it "should return the expected hash", ->
			expectedCommPct = 76.2
			expectedResPct = 82.3
			x = 
				residentialOccupancyPercent: expectedResPct
				commercialOccupancyPercent: expectedCommPct
			operatingIncome.set x, {silent: true}
			expected = 
				grossResidentialIncome:          operatingIncome.grossResidentialIncome()
				grossCommercialIncome:           operatingIncome.grossCommercialIncome()
				commercialOccupancyPercent:      expectedCommPct
				residentialOccupancyPercent:     expectedResPct
				effectiveGrossCommercialIncome:  operatingIncome.effectiveGrossCommercialIncome()
				effectiveGrossResidentialIncome: operatingIncome.effectiveGrossResidentialIncome()
			expect(operatingIncome.toJSON()).toEqual(expected)
		
	
	describe "validation", ->
		seventyPercentFloat = 70.0
		eventSpy = null
		validAttrs = null
		errorMsg = null

		beforeEach ->
			validAttrs =
				residentialOccupancyPercent: seventyPercentFloat
				# monthlyRent: somePositiveNumber
				# units: somePositiveNumber
			# operating?Income.set validAttrs, {silent: true}
			eventSpy = sinon.spy()
			operatingIncome.bind("error", eventSpy)

		afterEach ->
			# operatingIncome.save #validAttrs
			expect(eventSpy.calledOnce).toBeTruthy()
			expect(eventSpy.calledWith(operatingIncome, [errorMsg])).toBeTruthy()
	
	
		describe "maxResidentialOccupancyPercent", ->
			beforeEach ->
				errorMsg = "Maximum residential occupancy percent must be between 0 and 100, inclusive"
		
			it "should not be greater than 100", ->
				operatingIncome.set {maxResidentialOccupancyPercent: 100.01}
			
			it "should not be less than 0", ->
				operatingIncome.set {maxResidentialOccupancyPercent: -0.01}
			
		describe "maxCommercialOccupancyPercent", ->
			beforeEach ->
				errorMsg = "Maximum commercial occupancy percent must be between 0 and 100, inclusive"
			
			it "should not be greater than 100", ->
				operatingIncome.set {maxCommercialOccupancyPercent: 100.01}

			it "should not be less than 0", ->
				operatingIncome.set {maxCommercialOccupancyPercent: -0.01}
		
		describe "residentialOccupancyPercent", ->
			
			it "should not be greater than 95 when no max residential occupancy set", ->
				expect(operatingIncome.has "maxResidentialOccupancyPercent").toBe false
				errorMsg = "Residential occupancy percent must be between 0 and 95, inclusive"
				operatingIncome.set {residentialOccupancyPercent: 95.01}
			
			it "should not be greater than max residential occupancy, when set", ->
				max = 92.5
				validAttrs.maxResidentialOccupancyPercent = max
				validAttrs.residentialOccupancyPercent = max + 0.01
				errorMsg = "Residential occupancy percent must be between 0 and #{max}, inclusive"
				operatingIncome.set validAttrs
		
		describe "commercialOccupancyPercent, when commercial income sources are present", ->

			beforeEach ->
				operatingIncomesStub = sinon.stub(operatingIncome, "hasNoCommercialIncomeSources")
				operatingIncomesStub.returns false
		
			afterEach ->
				operatingIncomesStub.restore()
		
			it "should not be greater than 80, when no max commercial occupancy set", ->
				expect(operatingIncome.has "maxCommercialOccupancyPercent").toBe false
				errorMsg = "Commercial occupancy percent must be between 0 and 80, inclusive"
				validAttrs.commercialOccupancyPercent = 95.01
				operatingIncome.set validAttrs

			it "should not be greater than max commercial occupancy, when set", ->
				max = 92.5
				validAttrs.maxCommercialOccupancyPercent = max
				validAttrs.commercialOccupancyPercent = max + 0.01
				errorMsg = "Commercial occupancy percent must be between 0 and #{max}, inclusive"
				operatingIncome.set validAttrs
			
	describe "spaceUtilizationHash", ->
		it "should be the expected hash when all income collections are non-empty", ->
			expected = 
				apartment: 
					unitMix: apartmentIncomes.unitsPerBedroomHash()
					totalSquareFeet: apartmentIncomes.totalSquareFeet()
					allSquareFootageIsProvided: apartmentIncomes.allSquareFootageIsProvided()
				otherResidential:
					totalSquareFeet: otherResidentialIncomes.totalSquareFeet()
					allSquareFootageIsProvided: otherResidentialIncomes.allSquareFootageIsProvided()
				commercial:
					totalSquareFeet: commercialIncomes.totalSquareFeet()
					allSquareFootageIsProvided: commercialIncomes.allSquareFootageIsProvided()
				commercialParkingIncomes:
					totalSquareFeet: commercialParkingIncomes.totalSquareFeet()
					allSquareFootageIsProvided: commercialParkingIncomes.allSquareFootageIsProvided()
				residentialParkingIncomes:
					totalSquareFeet: residentialParkingIncomes.totalSquareFeet()
					allSquareFootageIsProvided: residentialParkingIncomes.allSquareFootageIsProvided()
			expect(operatingIncome.spaceUtilizationHash()).toEqual expected
		
		it "should be the expected hash when some income collections are empty", ->
			otherResidentialIncomes = new Backbone.Collection
			otherResidentialIncomes.isEmpty = -> true
			otherResidentialIncomes.fetch = -> # no op
			otherResidentialIncomesStub.returns otherResidentialIncomes
						
			otherResidentialParkingIncomes = new Backbone.Collection
			otherResidentialParkingIncomes.isEmpty = -> true
			otherResidentialParkingIncomes.fetch = -> # no op
			residentialParkingIncomesStub.returns otherResidentialParkingIncomes

			operatingIncome = new TodoApp.OperatingIncome

			expected = 
				apartment: 
					unitMix: apartmentIncomes.unitsPerBedroomHash()
					totalSquareFeet: apartmentIncomes.totalSquareFeet()
					allSquareFootageIsProvided: apartmentIncomes.allSquareFootageIsProvided()
				otherResidential: null
				commercial:
					totalSquareFeet: commercialIncomes.totalSquareFeet()
					allSquareFootageIsProvided: commercialIncomes.allSquareFootageIsProvided()
				commercialParkingIncomes:
					totalSquareFeet: commercialParkingIncomes.totalSquareFeet()
					allSquareFootageIsProvided: commercialParkingIncomes.allSquareFootageIsProvided()
				residentialParkingIncomes: null
			expect(operatingIncome.spaceUtilizationHash()).toEqual expected
			
	describe "resizeLoan event", ->
		eventSpy = null
		
		beforeEach ->
			eventSpy = sinon.spy()
			operatingIncome.bind("resizeLoan", eventSpy)
			operatingIncomesStub = sinon.stub(operatingIncome, "validate")
			operatingIncomesStub.returns undefined
		
		afterEach ->
			expect(eventSpy.calledOnce).toBeTruthy()
			operatingIncomesStub.restore()
		
		describe "maybeTriggerResizeLoan", ->
			it "should trigger event when at least one apt income source and model is valid", ->
				operatingIncome.maybeTriggerResizeLoan()
			
		
		it "should fire when some member collection changes, at least one apt income source and valid model", ->
			operatingIncome.commercialParkingIncomes.trigger('change')
		
		it "should fire when commercial occupancy changes in the presence of commercial income and valid model", ->
			expect(operatingIncome.hasNoCommercialIncomeSources()).toBe false
			operatingIncome.set {commercialOccupancyPercent: 78}
			
		it "should fire when residential occupancy changes in the presence of valid model", ->
			operatingIncome.set {residentialOccupancyPercent: 89}
		
