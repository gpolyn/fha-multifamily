class TodoApp.IncomeSources extends Backbone.Collection

	nextOrder: ->
		if @length then @last().get('order') + 1 else 1
	
	comparator: (incomeSource) ->
		incomeSource.get "order"
	
	totalAnnualIncome: ->
		val = 0
		_(@each (inc) -> val += inc.grossAnnualIncome())
		# console?.log "#{_(@reduce (s, t) -> s + t.totalAnnualUnitRent())}"
		val
	
	totalSquareFeet: ->
		val = 0
		_(@each (inc) -> val += inc.totalSquareFeet() ? 0)
		val
	
	allSquareFootageIsProvided: ->
		val = true
		func = (inc) -> inc.get('squareFeet') is undefined or inc.get('squareFeet') is null
		_(@each (inc) -> val = false if func(inc))
		val

class TodoApp.ApartmentIncomes extends TodoApp.IncomeSources
	
	model: TodoApp.ApartmentIncome
	
	localStorage: new Store("apartmentIncomes")
	
	unitsPerBedroomHash: ->
		hash = 
			zeroBedroomUnits: @totalUnitsForBedroomType 0
			oneBedroomUnits: @totalUnitsForBedroomType 1
			twoBedroomUnits: @totalUnitsForBedroomType 2
			threeBedroomUnits: @totalUnitsForBedroomType 3
			fourBedroomUnits: @totalUnitsForBedroomType 4
	
	# totalZeroBedroomUnits: ->
	# 	val = 0
	# 	_(@each (inc) -> val += inc.get('units') if inc.get('bedrooms') is 0)
	# 	val
	# 
	# totalOneBedroomUnits: ->
	# 	val = 0
	# 	_(@each (inc) -> val += inc.get('units') if inc.get('bedrooms') is 1)
	# 	val
	# 
	# totalThreeBedroomUnits: ->
	# 	val = 0
	# 	_(@each (inc) -> val += inc.get('units') if inc.get('bedrooms') is 3)
	# 	val
	# 
	# totalFourBedroomUnits: ->
	# 	val = 0
	# 	_(@each (inc) -> val += inc.get('units') if inc.get('bedrooms') is 4)
	# 	val
	
	totalUnitsForBedroomType: (br) ->
		# func = (memo, inc) -> memo + inc.get('units') if inc.get('bedrooms') is br
		# expected = _.reduce(apts, func, 0)
		val = 0
		# _(@reduce inc, func, 0)
		_(@each (inc) -> val += inc.get('units') if inc.get('bedrooms') is br)
		val
	

class TodoApp.CommercialIncomes extends TodoApp.IncomeSources

	model: TodoApp.CommercialIncome

	localStorage: new Store("commercialIncomes")

class TodoApp.OtherResidentialIncomes extends TodoApp.IncomeSources

	model: TodoApp.OtherResidentialIncome

	localStorage: new Store("otherResidentialIncomes")

class TodoApp.ParkingIncomes extends TodoApp.IncomeSources

	totalSquareFeetHelper: (which) ->
		val = 0
		_(@each (inc) -> val += inc.totalSquareFeet() if inc.get("outdoorOrIndoor") is which)
		val

	totalOutdoorSquareFeet: ->
		@totalSquareFeetHelper "outdoor"
	
	totalIndoorSquareFeet: ->
		@totalSquareFeetHelper "indoor"
	

class TodoApp.CommercialParkingIncomes extends TodoApp.IncomeSources

	model: TodoApp.CommercialParkingIncome

	localStorage: new Store("commercialParkingIncomes")

class TodoApp.ResidentialParkingIncomes extends TodoApp.IncomeSources

	model: TodoApp.ResidentialParkingIncome

	localStorage: new Store("residentialParkingIncomes")
