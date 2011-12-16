class TodoApp.IncomeSource extends Backbone.Model
	
	isANumberGreaterThan0: (attr) ->
		typeof attr is 'number' and attr > 0
	
	isAPositiveNumber: (attr) ->
		typeof attr is 'number' and 0 <= attr
	
	grossAnnualIncome: -> throw new Error('IncomeSource is an abstract class')

	totalSquareFeet: -> throw new Error('IncomeSource is an abstract class')

# ApartmentIncome Model
# ----------

# Would prefer to require this from the helpers file, but, oh well
isInteger = (num) ->
	num is Math.round(num)

# The basic unit of apartment income.
class TodoApp.ApartmentIncome extends TodoApp.IncomeSource
		
	validate: (attrs) ->
		console?.log "ApartmentIncome validate"
		errors = []
		
		if [0, 1, 2, 3, 4].indexOf(attrs.bedrooms) is -1
			errors.push("Bedrooms must be one of 0, 1, 2, 3 or 4")
		
		unless @isANumberGreaterThan0(attrs.monthlyRent)
			errors.push("Monthly apartment rent must be greater than $0")
		
		unless @unitsIsValid(attrs.units)
			errors.push "Apartment units must be an integer greater than 0"
		console?.log "squareFeet is #{attrs.squareFeet}"
		console?.log "previous squareFeet was #{@previous 'squareFeet'}"
		if attrs.squareFeet?		
			unless @isANumberGreaterThan0(attrs.squareFeet)
				errors.push "If provided, apartment square feet must be greater than 0"
		console?.log "ApartmentIncome validation, errors: #{errors.length}"
		errors if errors.length > 0
	
	unitsIsValid: (units) ->
		isInteger(units) and units > 0
	
	grossAnnualIncome: ->
		@totalAnnualUnitRent()
	
	totalAnnualUnitRent: ->
		rent = @get("monthlyRent")
		units = @get("units")
		return unless @isAPositiveNumber(rent) and @unitsIsValid(units)
		12 * rent * units
	
	totalSquareFeet: ->
		sf = @get("squareFeet")
		units = @get("units")
		return unless @isANumberGreaterThan0(sf) and @unitsIsValid(units)
		sf * units
	
	
# parent of simple income sources -- those having only rent and square footage
# attributes to validate
class TodoApp.SimpleIncome extends TodoApp.IncomeSource
	
	validate: (attrs) ->
		console?.log "SimpleIncome validate..."
		errors = []
		console?.log "...attrs.squareFeet is #{attrs.squareFeet}"
		unless @isANumberGreaterThan0(attrs.monthlyRent)
			errors.push @rentErrorMessage

		if attrs.squareFeet?
			console?.log "...square feet deemed present..."
			unless @isANumberGreaterThan0(attrs.squareFeet)
				errors.push @squareFeetErrorMessage
		console?.log "...errors #{errors.length}"
		errors if errors.length > 0
	
	grossAnnualIncome: ->
		rent = @get("monthlyRent")
		return unless @isANumberGreaterThan0(rent)
		12 * rent
	
	totalSquareFeet: ->
		sf = @get("squareFeet")
		return unless @isANumberGreaterThan0(sf)
		sf

# The basic unit of commercial income.
class TodoApp.CommercialIncome extends TodoApp.SimpleIncome
	
	initialize: ->
		@squareFeetErrorMessage = "If provided, commercial square feet must be greater than 0"
		@rentErrorMessage = "Monthly commercial rent must be greater than $0"
		super
	

# The basic unit of other residential income.
class TodoApp.OtherResidentialIncome extends TodoApp.SimpleIncome
	
	initialize: ->
		@squareFeetErrorMessage = "If provided, other income square feet must be greater than 0"
		@rentErrorMessage = "Monthly other income must be greater than $0"
		super
	

# The basic unit of parking income.
class TodoApp.ParkingIncome extends TodoApp.IncomeSource

	validate: (attrs) ->
		console?.log "ParkingIncome validate"
		errors = []

		if ["outdoor", "indoor"].indexOf(attrs.outdoorOrIndoor) is -1
			errors.push("Parking must be either outdoor or indoor")

		unless @isAPositiveNumber(attrs.monthlyFee)
			errors.push("Monthly parking fee be greater than or equal to $0")
		console?.log "ParkingIncome monthlyFee #{attrs.monthlyFee}"
		unless @spacesIsValid(attrs.spaces)
			errors.push "Parking spaces must be an integer greater than 0"

		if attrs.squareFeet?		
			unless @isANumberGreaterThan0(attrs.squareFeet)
				errors.push "If provided, parking square feet must be greater than 0"
		console?.log "ParkingIncome validate errors #{errors.length} and error is #{errors[0]}"
		errors if errors.length > 0

	spacesIsValid: (units) ->
		isInteger(units) and units > 0
	
	grossAnnualIncome: ->
		fee = @get("monthlyFee")
		spaces = @get("spaces")
		return unless @isAPositiveNumber(fee) and @spacesIsValid(spaces)
		12 * fee * spaces
	
	totalSquareFeet: ->
		sf = @get("squareFeet")
		return unless @isANumberGreaterThan0(sf)
		sf
	
# The basic unit of commercial parking income.
class TodoApp.CommercialParkingIncome extends TodoApp.ParkingIncome
		
# The basic unit of residential parking income.
class TodoApp.ResidentialParkingIncome extends TodoApp.ParkingIncome
	
