describe "Sec223fAcquisitionCosts", ->
	costs = null
	
	describe "inheritance from TodoApp.SingletonLikeModel", ->
		
		it "should be an instance of TodoApp.SingletonLikeModel", ->
			expect((new TodoApp.Sec223fAcquisitionCosts) instanceof TodoApp.SingletonLikeModel).toBe true
	
		it "should implement abstract localStorage class method", ->
			expect(TodoApp.Sec223fAcquisitionCosts.localStorage() instanceof Store).toBe true
			expect(TodoApp.Sec223fAcquisitionCosts.localStorage().name).toEqual "sec223fAcquisitionCosts"
	
	describe "localStorage", ->
		beforeEach ->
			costs = new TodoApp.Sec223fAcquisitionCosts
		
		it "should be an instance of Store", ->
			expect(costs.localStorage instanceof Store).toBe true

		it "should have a Store with the name 'sec223fAcquisitionCosts'", ->
			expect(costs.localStorage.name).toEqual 'sec223fAcquisitionCosts'
	
	describe "validation", ->
		eventSpy = null
		validAttrs = null
		errorMsg = null
		
		beforeEach ->
			validAttrs =
				purchasePrice: 77
				mortgageInterestRate: 5.66
			costs = new TodoApp.Sec223fAcquisitionCosts
			eventSpy = sinon.spy()
			costs.bind("error", eventSpy)

		afterEach ->
			costs.save validAttrs
			expect(eventSpy.calledOnce).toBeTruthy()
			expect(eventSpy.calledWith(costs, [errorMsg])).toBeTruthy()
		
		describe "purchasePrice", ->
			
			beforeEach ->
				validAttrs = {mortgageInterestRate: 5.66}
				errorMsg = "Purchase price must be greater than 0"
			
			it "must be present", ->
				expect(validAttrs.purchasePrice).toBe undefined
			
			it "must be greater than 0", ->
				validAttrs.purchasePrice = 0
			
		describe "repairsOrImprovements", ->
			it "must not be negative, when present", ->
				errorMsg = "Repairs/improvements, when provided, must be greater than or equal to 0"
				validAttrs.repairsOrImprovements = -0.01
			
		
		describe "replacementReservesOnDeposit", ->
			it "must not be negative, when present", ->
				errorMsg = "Replacement reserves on deposit, when provided, must be greater than or equal to 0"
				validAttrs.replacementReservesOnDeposit = -0.01
			
		
		describe "majorMovableEquipment", ->
			it "must not be negative, when present", ->
				errorMsg = "Major movable equipment, when provided, must be greater than or equal to 0"
				validAttrs.majorMovableEquipment = -0.01
			
		
		describe "initialDepositToReplacementReserve", ->
			it "must not be negative, when present", ->
				errorMsg = "Initial deposit to replacement reserve, when provided, must be greater than or equal to 0"
				validAttrs.initialDepositToReplacementReserve = -0.01
			
		
		describe "value", ->
			it "must not be negative, when present", ->
				errorMsg = "Value, when provided, must be greater than or equal to 0"
				validAttrs.value = -0.01
		
		describe "financingFee", ->
			
			it "must not be negative, when present", ->
				errorMsg = "Financing fee, when provided, must be greater than or equal to 0"
				validAttrs.financingFee = -0.01
			
			describe "when financingFeeIsPercentOfLoan is true", ->
				it "must be less than or equal to 100", ->
					errorMsg = "Financing fee as a percent, when provided, must be less than or equal to 100"
					validAttrs.financingFee = 100.01
					validAttrs.financingFeeIsPercentOfLoan = true
				
		describe "legalAndOrganizational", ->
			it "must not be negative, when present", ->
				errorMsg = "Legal and organizational, when provided, must be greater than or equal to 0"
				validAttrs.legalAndOrganizational = -0.01
		
		describe "titleAndRecording", ->

			it "must not be negative, when present", ->
				errorMsg = "Title and recording, when provided, must be greater than or equal to 0"
				validAttrs.titleAndRecording = -0.01

			describe "when titleAndRecordingIsPercentOfLoan is true", ->
				it "must be less than or equal to 100", ->
					errorMsg = "Title and recording as a percent, when provided, must be less than or equal to 100"
					validAttrs.titleAndRecording = 100.01
					validAttrs.titleAndRecordingIsPercentOfLoan = true
				
			
		
		describe "thirdPartyReports", ->
			it "must not be negative, when present", ->
				errorMsg = "Third party reports, when provided, must be greater than or equal to 0"
				validAttrs.thirdPartyReports = -0.01
		
		describe "other", ->
			it "must not be negative, when present", ->
				errorMsg = "Other, when provided, must be greater than or equal to 0"
				validAttrs.other = -0.01
		
		describe "survey", ->
			it "must not be negative, when present", ->
				errorMsg = "Survey, when provided, must be greater than or equal to 0"
				validAttrs.survey = -0.01
			
		
		describe "annualSpecialAssessment", ->
			it "must not be negative, when present", ->
				errorMsg = "Annual special assessment, when provided, must be greater than or equal to 0"
				validAttrs.annualSpecialAssessment = -0.01
			
		
		describe "annualReplacementReservePerUnit", ->
			it "must not be negative, when present", ->
				errorMsg = "Annual replacement reserve per unit, when provided, must be greater than or equal to 0"
				validAttrs.annualReplacementReservePerUnit = -0.01
			
		
		describe "mortgageInterestRate", ->
			it "must be present", ->
				errorMsg = "Mortgage interest rate must be greater than 0"
				validAttrs = {purchasePrice: 77}
				expect(validAttrs.mortgageInterestRate).toBe undefined
			
			it "must be greater than 0", ->
				errorMsg = "Mortgage interest rate must be greater than 0"
				validAttrs.mortgageInterestRate = 0
			
			it "must be less than 100", ->
				errorMsg = "Mortgage interest rate must be less than 100"
				validAttrs.mortgageInterestRate = 100
			
		
	describe "toJSON", ->
		it "should be the expected hash, numnuts", ->
			attrs = {id: 2312312}
			expected = 
				purchasePrice: 12331
				mortgageInterestRate: 8.76
				value: 676474
				repairsOrImprovements: 8799
				replacementReservesOnDeposit: 10900
				majorMovableEquipment: 90909
				initialDepositToReplacementReserve: 909099
				financingFee: 3.4
				financingFeeIsPercentOfLoan: true
				legalAndOrganizational: 192909
				titleAndRecording: 0.78
				titleAndRecordingIsPercentOfLoan: true
				thirdPartyReports: 900
				other: undefined
				survey: undefined
				annualSpecialAssessment: 200
				annualReplacementReservePerUnit: 275
			_.extend attrs, expected
			costs = new TodoApp.Sec223fAcquisitionCosts attrs
			expect(costs.toJSON()).toEqual expected
