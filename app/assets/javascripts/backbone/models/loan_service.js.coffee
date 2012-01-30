class TodoApp.LoanService extends Backbone.Model
	
	initialize: ->
		@criteria = @attributes.criteria
		@loanSubmission = @attributes.loanSubmission
		@attributes.loanCosts.bind "change", => @updateCriteriaUrl()
		@loanSubmission.bind "change", => @updateCriteriaUrl()
		@updateCriteriaUrl()
	
	initializeForConstantUpdating: ->
		@criteria = @attributes.criteria
		@attributes.operating.bind "resizeLoan", => @updateOperatingHashAndGetLoan()
		@attributes.affordability.bind "change", => @updateAffordabilityHashAndGetLoan()
		@attributes.metropolitanArea.bind "change", => @updateMetropolitanAreaHashAndGetLoan()
		@attributes.loanCosts.bind "resizeLoan", => @updateLoanCostsHashAndGetLoan()
		@toJSONHash = 
			operating:        @attributes.operating.toJSON()
			affordability:    @attributes.affordability.toJSON()
			metropolitanArea: @attributes.metropolitanArea.toJSON()
			loanCosts:        @attributes.loanCosts.toJSON()
	
	updateCriteriaUrl: ->
		@attributes.criteria.url = "api/beta1/sec223f_" + if @isPurchase()
			"acquisition.json?api_key=#{@attributes.loanSubmission.get('apiKey')}"
		else
			"refinance.json?api_key=#{@attributes.loanSubmission.get('apiKey')}"
	
	isValidForSubmission: ->
		retArr = new Array
		retArr.push("apiKey") unless @attributes.loanSubmission.get('apiKey')?
		retArr.push('apartmentIncome') unless @attributes.operating.attributes.operatingIncome.apartmentIncomes.length > 0
		unless @attributes.operating.attributes.operatingIncome.attributes.residentialOccupancyPercent >= 0
			retArr.push('residentialOccupancyPercent') 
		unless @attributes.operating.attributes.operatingIncome.hasNoCommercialIncomeSources()
			unless @attributes.operating.attributes.operatingIncome.attributes.commercialOccupancyPercent >= 0
				retArr.push 'commercialOccupancyPercent'
		unless @attributes.operating.attributes.operatingExpense.attributes.total >= 0
			retArr.push('operatingExpense') 
		retArr.push('transactionAmount') unless @attributes.loanCosts.attributes.transactionAmount >= 0
		retArr.push('termInMonths') unless @attributes.loanCosts.attributes.termInMonths >= 0
		retArr.push('mortgageInterestRate') unless @attributes.loanCosts.attributes.mortgageInterestRate >= 0
		retArr.push('loanRequest') unless @attributes.loanCosts.attributes.loanRequest >= 0
		if @attributes.loanCosts.attributes.transactionAmountType == "debt"
			retArr.push('value') unless @attributes.loanCosts.attributes.value >= 0
		if retArr.length > 0 then retArr else true
	
	updateOperatingHashAndGetLoan: ->
		@toJSONHash.operating = @attributes.operating.toJSON()
		@criteria.fetch({data: @toJSON()})
	
	updateAffordabilityHashAndGetLoan: ->
		@toJSONHash.affordability = @attributes.affordability.toJSON()
		@criteria.fetch({data: @toJSON()})
	
	updateMetropolitanAreaHashAndGetLoan: ->
		@toJSONHash.metropolitanArea = @attributes.metropolitanArea.toJSON()
		@criteria.fetch({data: @toJSON()})
	
	updateLoanCostsHashAndGetLoan: ->
		@toJSONHash.loanCosts = @attributes.loanCosts.toJSON()
		@criteria.fetch({data: @toJSON()})
	
	isPurchase: ->
		@attributes.loanCosts.get('transactionAmountType') == "purchase"
	
	fetch: (options) ->
		options || (options = {})
		
		collection = @criteria
		model = @
		
		options.success = (resp) ->
			console.log "success is #{JSON.stringify(resp)}"
			
			model.saveCashRequirementToLocalStorage resp.total_estimated_cash_requirement
			model.saveLoanAmountToLocalStorage resp.loan.maximum_insurable_mortgage

			arr = collection.plarse(resp)
			collection.destroyAll()
			for ele in arr
				collection.create(ele)
			collection.trigger "refresh"
		
		params =
			type:        'POST'
			dataType:    'json'
			url:          @criteria.url
			contentType: 'application/json'
			data:         JSON.stringify(@toJSONforFetch())

		if Backbone.emulateJSON
			params.contentType = 'application/x-www-form-urlencoded'
			params.data        = if options.data then {model : options.data} else {}
		
		_.extend params, options
		$.ajax(params)
		@
	
	minimumPurchaseRequest: ->
		req =
			affordability: affordable
			purchase_price_of_project: 1113300,
			loan_request: 750000
			metropolitan_area_waiver: "maximum waiver"
			number_of_one_bedroom_units: 1
			number_of_three_bedroom_units: 1
			number_of_no_bedroom_units: 3
			is_elevator_project: true
			mortgage_interest_rate: 4.5
			gross_residential_income: 102000
			residential_occupancy_percent: 93
			operating_expenses: 40
			operating_expenses_is_percent_of_effective_gross_income: true
			annual_replacement_reserve_per_unit: 250
			term_in_months: 420
		req
	
	# save: (attrs, options) ->
	# 	throw new Error "Persistence-related actions not available in this class"
	
	#destroy: (options) ->
	#	throw new Error "Persistence-related actions not available in this class"
	
	hasLoanAmountAndCashRequirementSaved: ->
		localStorage.getItem('cashRequirement')? and localStorage.getItem('loanAmount')?
	
	deleteLoanAmountAndCashRequirementFromLocalStorage: ->
		@deleteCashRequirementFromLocalStorage()
		@deleteLoanAmountFromLocalStorage()
		
	deleteCashRequirementFromLocalStorage: ->
		localStorage.removeItem('cashRequirement')
	
	deleteLoanAmountFromLocalStorage: ->
		localStorage.removeItem('loanAmount')
	
	saveCashRequirementToLocalStorage: (cashRequirement)->
		localStorage.setItem('cashRequirement', cashRequirement)
	
	getCashRequirementFromLocalStorage: ->
		localStorage.getItem('cashRequirement')
	
	saveLoanAmountToLocalStorage: (loanAmount)->
		localStorage.setItem('loanAmount', loanAmount)
	
	getLoanAmountFromLocalStorage: ->
		localStorage.getItem('loanAmount')
	
	toJSONforFetch: ->
		oper = @attributes.operating.toJSON()
		lc = @attributes.loanCosts.toJSON()
		ret =
			number_of_no_bedroom_units: oper.spaceUtilization.apartment.unitMix.zeroBedroomUnits
			number_of_one_bedroom_units: oper.spaceUtilization.apartment.unitMix.oneBedroomUnits
			number_of_two_bedroom_units: oper.spaceUtilization.apartment.unitMix.twoBedroomUnits
			number_of_three_bedroom_units: oper.spaceUtilization.apartment.unitMix.threeBedroomUnits
			number_of_four_or_more_bedroom_units: oper.spaceUtilization.apartment.unitMix.fourBedroomUnits
			gross_apartment_square_feet: oper.spaceUtilization.apartment.totalSquareFeet
			gross_commercial_square_feet: oper.spaceUtilization.commercial.totalSquareFeet if oper.spaceUtilization.commercial?
			gross_other_square_feet: oper.spaceUtilization.otherResidential.totalSquareFeet if oper.spaceUtilization.otherResidential?
			outdoor_commercial_parking_square_feet: oper.spaceUtilization.commercialParkingIncomes.totalOutdoorSquareFeet if oper.spaceUtilization.commercialParkingIncomes?
			indoor_commercial_parking_square_feet: oper.spaceUtilization.commercialParkingIncomes.totalIndoorSquareFeet if oper.spaceUtilization.commercialParkingIncomes?
			outdoor_residential_parking_square_feet: oper.spaceUtilization.residentialParkingIncomes.totalOutdoorSquareFeet if oper.spaceUtilization.residentialParkingIncomes?
			indoor_residential_parking_square_feet: oper.spaceUtilization.residentialParkingIncomes.totalIndoorSquareFeet if oper.spaceUtilization.residentialParkingIncomes?
			gross_residential_income: oper.operatingIncome.grossResidentialIncome
			gross_commercial_income: oper.operatingIncome.grossCommercialIncome
			commercial_occupancy_percent: oper.operatingIncome.commercialOccupancyPercent
			residential_occupancy_percent: oper.operatingIncome.residentialOccupancyPercent
			operating_expenses: oper.operatingExpense.total
			operating_expenses_is_percent_of_effective_gross_income: oper.operatingExpense.totalIsPercentOfEffectiveGrossIncome
			warranted_price_of_land: lc.landValue
			value_in_fee_simple: lc.value
			mortgage_interest_rate: lc.mortgageInterestRate
			annual_replacement_reserve_per_unit: lc.annualReplacementReservesPerUnit
			loan_request: lc.loanRequest
			term_in_months: lc.termInMonths
			legal_and_organizational: lc.legalAndOrganizational
			third_party_reports: lc.thirdPartyReports
			survey: lc.survey
			other: lc.other
			financing_fee_is_percent_of_loan: lc.financingFeeIsPercentOfLoan
			financing_fee: lc.financingFee
			title_and_recording_is_percent_of_loan: lc.titleAndRecordingIsPercentOfLoan
			title_and_recording: lc.titleAndRecording
			affordability: @attributes.affordability.toJSON().level
			metropolitan_area_waiver: @attributes.metropolitanArea.toJSON().value
			is_elevator_project: @attributes.elevatorStatus.toJSON().hasElevator
			
		if @isPurchase()
			ret.purchase_price_of_project = lc.transactionAmount
			ret.repairs_and_improvements = lc.repairsOrImprovements
		else
			ret.existing_indebtedness = lc.transactionAmount
			ret.repairs = lc.repairsOrImprovements
		ret