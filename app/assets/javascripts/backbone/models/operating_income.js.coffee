# Container for all income source collections, plus additional methods for 
# aggregation and vacancy adjustment.
class TodoApp.OperatingIncome extends Backbone.Model
	
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
				# console.log "OperatingIncome about to trigger resizeLoan"
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
		
		unless @hasNoCommercialIncomeSources()
			maxCommercial = @determineMaxCommercialOccupancyPercent(attrs.maxCommercialOccupancyPercent)
			
			if maxCommercial < attrs.commercialOccupancyPercent or attrs.commercialOccupancyPercent < 0
				errors.push "Commercial occupancy percent must be between 0 and #{maxCommercial}, inclusive"
		console?.log "errors[0] #{errors[0]}"
		errors if errors.length > 0
	
	occupancyPercentIsValid: (pct) ->
		pct <= 100 and pct >= 0
	
	determineMaxResidentialOccupancyPercent: (testVal) ->
		return testVal if testVal? and @occupancyPercentIsValid testVal
		95
	
	determineMaxCommercialOccupancyPercent: (testVal) ->
		return testVal if testVal? and @occupancyPercentIsValid testVal
		80
	
	effectiveGrossCommercialIncome: ->
		return unless income = @grossCommercialIncome()
		return unless pct = @get 'commercialOccupancyPercent'
		income * parseFloat(pct)/100
	
	effectiveGrossResidentialIncome: ->
		return unless income = @grossResidentialIncome()
		return unless pct = @get 'residentialOccupancyPercent'
		income * parseFloat(pct)/100
	
	effectiveGrossIncome: ->
		return null unless residentialEGI = @effectiveGrossResidentialIncome()
		return null unless commercialEGI = @effectiveGrossCommercialIncome()
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
				allSquareFootageIsProvided: @commercialParkingIncomes.allSquareFootageIsProvided()
		
		unless @residentialParkingIncomes.isEmpty()
			residentialParkingHash = 
				totalSquareFeet: @residentialParkingIncomes.totalSquareFeet()
				allSquareFootageIsProvided: @residentialParkingIncomes.allSquareFootageIsProvided()
		
		hash = 
			apartment: aptHash
			otherResidential: otherResidentialHash
			commercial: commercialHash
			commercialParkingIncomes: commercialParkingHash
			residentialParkingIncomes: residentialParkingHash
	
