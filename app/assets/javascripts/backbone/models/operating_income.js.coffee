# Container for all income source collections, plus additional methods for 
# aggregation and vacancy adjustment.
class TodoApp.OperatingIncome extends Backbone.Model
	
	# @localStorage: -> new Store "operatingIncome"
	
	# localStorage: @localStorage()
	
	localStorage: new Store("operatingIncome")
	
	initialize: ->
		
		unless @attributes.apartmentIncomes?
			@apartmentIncomes = new TodoApp.ApartmentIncomes
			@apartmentIncomes.fetch()
		else
			@apartmentIncomes = @attributes.apartmentIncomes
		
		unless @attributes.commercialIncomes?
			@commercialIncomes = new TodoApp.CommercialIncomes
			@commercialIncomes.fetch()
		else
			@commercialIncomes = @attributes.commercialIncomes
			
		unless @attributes.commercialParkingIncomes?
			@commercialParkingIncomes = new TodoApp.CommercialParkingIncomes
			@commercialParkingIncomes.fetch()
		else
			@commercialParkingIncomes = @attributes.commercialParkingIncomes
		
		unless @attributes.residentialParkingIncomes?
			@residentialParkingIncomes = new TodoApp.ResidentialParkingIncomes
			@residentialParkingIncomes.fetch()
		else
			@residentialParkingIncomes = @attributes.residentialParkingIncomes
		
		unless @attributes.otherResidentialIncomes?
			@otherResidentialIncomes = new TodoApp.OtherResidentialIncomes
			@otherResidentialIncomes.fetch()
		else
			@otherResidentialIncomes = @attributes.otherResidentialIncomes
		
		@bind "change", => @maybeTriggerResizeLoan()
		
		@bindThisChangeToCollectionEvents @commercialParkingIncomes
		@bindThisChangeToCollectionEvents @commercialIncomes
		@bindThisChangeToCollectionEvents @apartmentIncomes
		@bindThisChangeToCollectionEvents @residentialParkingIncomes
		@bindThisChangeToCollectionEvents @otherResidentialIncomes
	
		
	bindThisChangeToCollectionEvents: (coll) ->
		coll.bind "change", => @maybeTriggerResizeLoanButThenTriggerChange()
		coll.bind "add", => @maybeTriggerResizeLoanButThenTriggerChange()
		coll.bind "remove", => @maybeTriggerResizeLoanButThenTriggerChange()
	
	maybeTriggerResizeLoan: ->
		unless @apartmentIncomes.isEmpty()
			if @validate(@attributes) is undefined
				# console?.log "OperatingIncome about to trigger resizeLoan"
				@trigger "resizeLoan"
	
	maybeTriggerResizeLoanButThenTriggerChange: ->
		@trigger "change"
	
	validate: (attrs) ->
		console?.log "OperatingIncome validate..."
		errors = []
		
		if attrs.maxResidentialOccupancyPercent
			unless @occupancyPercentIsValid attrs.maxResidentialOccupancyPercent
				errors.push "Maximum residential occupancy percent must be between 0 and 100, inclusive"
		
		if attrs.maxCommercialOccupancyPercent
			unless @occupancyPercentIsValid attrs.maxCommercialOccupancyPercent
				errors.push "Maximum commercial occupancy percent must be between 0 and 100, inclusive"
		
		maxResidential = @determineMaxResidentialOccupancyPercent(attrs.maxResidentialOccupancyPercent)
		
		if maxResidential < attrs.residentialOccupancyPercent or attrs.residentialOccupancyPercent < 0
			errors.push "Residential occupancy percent must be between 0 and #{maxResidential}, inclusive"
		
		unless @hasNoCommercialIncomeSources() and attrs.commercialOccupancyPercent is null
			maxCommercial = @determineMaxCommercialOccupancyPercent(attrs.maxCommercialOccupancyPercent)
			label = "Commercial occupancy percent"
			attrs.commercialOccupancyPercent = @occupancyPercentIsValid(errors, attrs.commercialOccupancyPercent, label)
		
			if maxCommercial < attrs.commercialOccupancyPercent or attrs.commercialOccupancyPercent < 0
				errors.push "Commercial occupancy percent must be between 0 and #{maxCommercial}, inclusive"
		console?.log "errors[0] #{errors[0]}"
		errors if errors.length > 0
	
	isValidForLoanSubmission: ->
		@get('commercialOccupancyPercent')?
	
	occupancyPercentIsValid: (errArr, attr, attrLabel) ->
		# pct <= 100 and pct >= 0
		if TodoApp.isNumber attr
			attr = parseFloat attr
			errArr.push "#{attrLabel} must be greater than or equal to 0" if attr < 0
			errArr.push "#{attrLabel} must be less than 100" unless attr < 100
		else
			console?.log "problem with occupancy percent not being number: #{attr}"
			errArr.push "#{attrLabel} must be greater than or equal to 0"
		attr
	
	determineMaxResidentialOccupancyPercent: (testVal) ->
		return testVal if testVal? and @occupancyPercentIsValid testVal
		95
	
	determineMaxCommercialOccupancyPercent: (testVal) ->
		return testVal if testVal? and @occupancyPercentIsValid testVal
		80
	
	effectiveGrossCommercialIncome: ->
		return unless income = @grossCommercialIncome()
		return unless pct = @get 'commercialOccupancyPercent'
		Math.round(income * parseFloat(pct)/100 * 100)/100
	
	effectiveGrossResidentialIncome: ->
		return unless income = @grossResidentialIncome()
		return unless pct = @get 'residentialOccupancyPercent'
		Math.round(income * parseFloat(pct)/100 * 100)/100
	
	effectiveGrossIncome: ->
		residentialEGI = @effectiveGrossResidentialIncome()
		commercialEGI = @effectiveGrossCommercialIncome()
		return null unless residentialEGI or commercialEGI
		residentialEGI = 0 if isNaN(residentialEGI)
		commercialEGI = 0 if isNaN(commercialEGI)
		residentialEGI + commercialEGI
	
	grossCommercialIncome: ->
		ret = @commercialParkingIncomes.totalAnnualIncome()
		ret += @commercialIncomes.totalAnnualIncome()
	
	grossResidentialIncome: ->
		ret = @apartmentIncomes.totalAnnualIncome()
		ret += @otherResidentialIncomes.totalAnnualIncome()
		ret += @residentialParkingIncomes.totalAnnualIncome()
	
	hasNoCommercialIncomeSources: ->
		@commercialIncomes.isEmpty() and @commercialParkingIncomes.isEmpty()
	
	toJSON: ->
		grossResidentialIncome:          @grossResidentialIncome()
		grossCommercialIncome:           @grossCommercialIncome()
		commercialOccupancyPercent:      @get('commercialOccupancyPercent')
		residentialOccupancyPercent:     @get('residentialOccupancyPercent')
		effectiveGrossCommercialIncome:  @effectiveGrossCommercialIncome()
		effectiveGrossResidentialIncome: @effectiveGrossResidentialIncome()
		effectiveGrossIncome:            @effectiveGrossIncome()
	
	spaceUtilizationHash: ->
		aptHash = null
		otherResidentialHash = null
		commercialHash = null
		commercialParkingHash = null
		residentialParkingHash = null
		
		unless @apartmentIncomes.isEmpty()
			aptHash = 
				unitMix: @apartmentIncomes.unitsPerBedroomHash()
				totalSquareFeet: @apartmentIncomes.totalSquareFeet()
				allSquareFootageIsProvided: @apartmentIncomes.allSquareFootageIsProvided()
		
		unless @otherResidentialIncomes.isEmpty()
			otherResidentialHash = 
				totalSquareFeet: @otherResidentialIncomes.totalSquareFeet()
				allSquareFootageIsProvided: @otherResidentialIncomes.allSquareFootageIsProvided()
		
		unless @commercialIncomes.isEmpty()
			commercialHash = 
				totalSquareFeet: @commercialIncomes.totalSquareFeet()
				allSquareFootageIsProvided: @commercialIncomes.allSquareFootageIsProvided()
		
		unless @commercialParkingIncomes.isEmpty()
			commercialParkingHash = 
				totalSquareFeet: @commercialParkingIncomes.totalSquareFeet()
				totalOutdoorSquareFeet: @commercialParkingIncomes.totalOutdoorSquareFeet()
				totalIndoorSquareFeet: @commercialParkingIncomes.totalIndoorSquareFeet()
				allSquareFootageIsProvided: @commercialParkingIncomes.allSquareFootageIsProvided()
		
		unless @residentialParkingIncomes.isEmpty()
			residentialParkingHash = 
				totalSquareFeet: @residentialParkingIncomes.totalSquareFeet()
				totalOutdoorSquareFeet: @residentialParkingIncomes.totalOutdoorSquareFeet()
				totalIndoorSquareFeet: @residentialParkingIncomes.totalIndoorSquareFeet()
				allSquareFootageIsProvided: @residentialParkingIncomes.allSquareFootageIsProvided()
		
		hash = 
			apartment: aptHash
			otherResidential: otherResidentialHash
			commercial: commercialHash
			commercialParkingIncomes: commercialParkingHash
			residentialParkingIncomes: residentialParkingHash
	
class TodoApp.Sec223fMultifamilyOperatingIncome extends TodoApp.OperatingIncome

	validate: (attrs) ->
		errors = super(attrs) or []
		
		maxResidential = @determineMaxResidentialOccupancyPercent
		
		if attrs.residentialOccupancyPercent < 85 or attrs.residentialOccupancyPercent > maxResidential
			errors.push "Residential occupancy percent must be between 85 and #{maxResidential}, inclusive"
			
		errors if errors.length > 0
	
	initialize: ->
		super
		
		@attributes.affordability.bind "change", => @blah()
		
		unless @attributes.residentialOccupancyPercent or @get 'residentialOccupancyPercent'
			@set({residentialOccupancyPercent: 85}, {silent: true})

	determineMaxResidentialOccupancyPercent: ->
		if @get('affordability') and @get('affordability').get('level') == "market"
			93
		else
			95
	
	blah: ->
		if @get('affordability') and @get('affordability').get('level') == "market"
			if @get('residentialOccupancyPercent') > 93
				@save {residentialOccupancyPercent: 93, commercialOccupancyPercent: @get 'commercialOccupancyPercent'}
	

	