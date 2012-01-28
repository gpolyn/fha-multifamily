class TodoApp.Sec223fCosts extends TodoApp.SingletonLikeModel
	
	isANumberGreaterThan0: (attr) ->
		typeof attr is 'number' and attr > 0
	
	isGreaterThanOrEqualTo250: (errArr, attr, attrLabel) ->
		if TodoApp.isNumber attr
			attr = parseFloat attr
			errArr.push "#{attrLabel} must be greater than or equal to 250" if attr < 250
		else
			errArr.push "#{attrLabel} must be greater than or equal to 250"	
		attr
	
	ifGivenThenIsANonNegativeNumber: (errArr, attr, attrLabel) ->
		if attr?
			if TodoApp.isNumber attr
				attr = parseFloat attr
				errArr.push "#{attrLabel} must be greater than or equal to 0" if attr < 0
			else
				errArr.push "#{attrLabel} must be greater than or equal to 0"
			attr
	
	ifGivenThenIsANonNegativeNumberLessThan100: (errArr, attr, attrLabel) ->
		if attr?
			if TodoApp.isNumber attr
				attr = parseFloat attr
				errArr.push "#{attrLabel} must be greater than or equal to 0" if attr < 0
				errArr.push "#{attrLabel} must be less than 100" unless attr < 100
			else
				errArr.push "#{attrLabel} must be greater than or equal to 0"
			attr
	
	ifGivenThenIsANonNegativeIntegerLessThan421: (errArr, attr, attrLabel) ->
		if attr?
			if TodoApp.isNumber attr
				attr = parseInt attr
				errArr.push "#{attrLabel} must be greater than or equal to 0" if attr < 0
				errArr.push "#{attrLabel} must be less than 420" unless attr < 421
			else
				errArr.push "#{attrLabel} must be greater than or equal to 0"
			attr
	
class TodoApp.Sec223fAcquisitionCosts extends TodoApp.Sec223fCosts
	
	@localStorage: -> new Store "sec223fAcquisitionCosts"
	
	localStorage: @localStorage()
	
	initialize: (attrs) ->
		@set({transactionAmountType: "purchase"}, {silent: true}) unless attrs.transactionAmountType
		@set({annualReplacementReservesPerUnit: 250}, {silent: true}) unless attrs.annualReplacementReservesPerUnit
		@set({termInMonths: 420}, {silent: true}) unless attrs.termInMonths
	
	validate: (attrs) ->
		errors = []
		
		if ["purchase", "debt"].indexOf(attrs.transactionAmountType) is -1
			errors.push("Transaction amount type must be one of 'purchase' or 'debt'")
		
		attrs.landValue = @ifGivenThenIsANonNegativeNumber errors, attrs.landValue, "Land value"
		attrs.loanRequest = @ifGivenThenIsANonNegativeNumber errors, attrs.loanRequest, "Loan request"
		attrs.transactionAmount = @ifGivenThenIsANonNegativeNumber errors, attrs.transactionAmount, "Transaction amount"
		attrs.value = @ifGivenThenIsANonNegativeNumber errors, attrs.value, "Value"
		attrs.termInMonths = @ifGivenThenIsANonNegativeIntegerLessThan421 errors, attrs.termInMonths, "Term in months"
		attrs.repairsOrImprovements = @ifGivenThenIsANonNegativeNumber errors, attrs.repairsOrImprovements, "Repairs/improvements"
		attrs.majorMovableEquipment = @ifGivenThenIsANonNegativeNumber errors, attrs.majorMovableEquipment, "Major movable equipment"
		attrs.thirdPartyReports = @ifGivenThenIsANonNegativeNumber errors, attrs.thirdPartyReports, "Third party reports"
		attrs.survey = @ifGivenThenIsANonNegativeNumber errors, attrs.survey, "Survey"
		attrs.legalAndOrganizational = @ifGivenThenIsANonNegativeNumber errors, attrs.legalAndOrganizational, "Legal and organizational"
		attrs.other = @ifGivenThenIsANonNegativeNumber errors, attrs.other, "Other"
		attrs.mortgageInterestRate = @ifGivenThenIsANonNegativeNumberLessThan100 errors, attrs.mortgageInterestRate, 
			"Mortgage interest rate"
		attrs.annualReplacementReservesPerUnit = @isGreaterThanOrEqualTo250 errors, attrs.annualReplacementReservesPerUnit, 
			"Annual replacement reserves per unit"
		attrs.replacementReserveOnDeposit = @ifGivenThenIsANonNegativeNumber errors, attrs.replacementReserveOnDeposit,
			"Replacement reserve on deposit"
		attrs.initialDepositToReplacementReserve = @ifGivenThenIsANonNegativeNumber errors, attrs.initialDepositToReplacementReserve, 
			"Initial deposit to replacement reserve"
		
		if [true, false].indexOf(attrs.financingFeeIsPercentOfLoan) is -1
			errors.push("Transaction amount type must be one of 'purchase' or 'debt'") 
		else
			attrs.financingFee = if attrs.financingFeeIsPercentOfLoan is true
				@ifGivenThenIsANonNegativeNumberLessThan100 errors, attrs.financingFee, 
					"Financing fee"
			else
				@ifGivenThenIsANonNegativeNumber errors, attrs.financingFee, "Financing fee"
		
		if [true, false].indexOf(attrs.titleAndRecordingIsPercentOfLoan) is -1
			errors.push("Title and recording is percent of loan must be true or false")
		else
			attrs.titleAndRecording = if attrs.titleAndRecordingIsPercentOfLoan is true
				@ifGivenThenIsANonNegativeNumberLessThan100 errors, attrs.titleAndRecording, "Title and recording"
			else
				@ifGivenThenIsANonNegativeNumber errors, attrs.titleAndRecording, "Title and recording"
		
		for err in errors
			console.log "loan cost error #{err}, "
		errors if errors.length > 0
	
	toJSON: ->
		transactionAmount: @get 'transactionAmount'
		transactionAmountType: @get 'transactionAmountType'
		mortgageInterestRate: @get 'mortgageInterestRate'
		loanRequest: @get 'loanRequest'
		landValue: @get 'landValue'
		value: @get 'value'
		termInMonths: @get 'termInMonths'
		repairsOrImprovements: @get 'repairsOrImprovements'
		replacementReserveOnDeposit: @get 'replacementReserveOnDeposit'
		majorMovableEquipment: @get 'majorMovableEquipment'
		initialDepositToReplacementReserve: @get 'initialDepositToReplacementReserve'
		financingFee: @get 'financingFee'
		financingFeeIsPercentOfLoan: @get 'financingFeeIsPercentOfLoan'
		legalAndOrganizational: @get 'legalAndOrganizational'
		titleAndRecording: @get 'titleAndRecording'
		titleAndRecordingIsPercentOfLoan: @get 'titleAndRecordingIsPercentOfLoan'
		thirdPartyReports: @get 'thirdPartyReports'
		other: @get 'other'
		survey: @get 'survey'
		annualSpecialAssessment: @get 'annualSpecialAssessment'
		annualReplacementReservesPerUnit: @get 'annualReplacementReservesPerUnit'
		
