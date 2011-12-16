class TodoApp.Sec223fCosts extends TodoApp.SingletonLikeModel
	
	isANumberGreaterThan0: (attr) ->
		typeof attr is 'number' and attr > 0
	
	isAPositiveNumber: (attr) ->
		typeof attr is 'number' and 0 <= attr
		
	addErrorIfOptionalAttributeIsNegative: (errArr, attrVar, attrLabel) ->
		optionalAttrErrMsg = ", when provided, must be greater than or equal to 0"
		if attrVar?
			unless @isAPositiveNumber attrVar
				errArr.push attrLabel + optionalAttrErrMsg

class TodoApp.Sec223fAcquisitionCosts extends TodoApp.Sec223fCosts
	
	@localStorage: -> new Store "sec223fAcquisitionCosts"
	
	localStorage: @localStorage()
	
	# initialize: ->
	# 	@bind 'change', 
	
	validate: (attrs) ->
		errors = []
		
		unless @isANumberGreaterThan0 attrs.purchasePrice
			errors.push "Purchase price must be greater than 0"
		
		if attrs.mortgageInterestRate?
			unless attrs.mortgageInterestRate > 0
				errors.push "Mortgage interest rate must be greater than 0"
			else
				unless attrs.mortgageInterestRate < 100
					errors.push "Mortgage interest rate must be less than 100"
		else
			errors.push "Mortgage interest rate must be greater than 0"
		
		@addErrorIfOptionalAttributeIsNegative errors, attrs.value, 
			"Value"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.repairsOrImprovements, 
			"Repairs/improvements"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.replacementReservesOnDeposit, 
			"Replacement reserves on deposit"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.majorMovableEquipment, 
			"Major movable equipment"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.initialDepositToReplacementReserve, 
			"Initial deposit to replacement reserve"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.financingFee, 
			"Financing fee"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.legalAndOrganizational, 
			"Legal and organizational"
		if attrs.financingFeeIsPercentOfLoan is true
			if attrs.financingFee > 100
				errors.push "Financing fee as a percent, when provided, must be less than or equal to 100"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.titleAndRecording, 
			"Title and recording"
		if attrs.titleAndRecordingIsPercentOfLoan is true
			if attrs.titleAndRecording > 100
				errors.push "Title and recording as a percent, when provided, must be less than or equal to 100"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.thirdPartyReports, 
			"Third party reports"		
		@addErrorIfOptionalAttributeIsNegative errors, attrs.other, 
			"Other"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.survey, 
			"Survey"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.annualSpecialAssessment, 
			"Annual special assessment"
		@addErrorIfOptionalAttributeIsNegative errors, attrs.annualReplacementReservePerUnit, 
			"Annual replacement reserve per unit"
			
		errors if errors.length > 0
	
	toJSON: ->
		purchasePrice: @get 'purchasePrice'
		mortgageInterestRate: @get 'mortgageInterestRate'
		value: @get 'value'
		repairsOrImprovements: @get 'repairsOrImprovements'
		replacementReservesOnDeposit: @get 'replacementReservesOnDeposit'
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
		annualReplacementReservePerUnit: @get 'annualReplacementReservePerUnit'
		
