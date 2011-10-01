# ApartmentIncome Model
# ----------

# Would prefer to require this from the helpers file, but, oh well
isInteger = (num) ->
	num is Math.round(num)

# The basic unit of apartment income.
class TodoApp.ApartmentIncome extends Backbone.Model
		
	validate: (attrs) ->
		errors = []
		
		if [0, 1, 2, 3, 4].indexOf(attrs.bedrooms) is -1
			errors.push("Bedrooms must be one of 0, 1, 2, 3 or 4")
		
		unless @attributeIsValid(attrs.monthlyRent)
			errors.push("Monthly apartment rent must be greater than $0")
		
		unless @unitsIsValid(attrs.units)
			errors.push "Apartment units must be an integer greater than 0"
		
		if attrs.squareFeet?		
			unless @attributeIsValid(attrs.squareFeet)
				errors.push "If provided, apartment square feet must be greater than 0"
		
		errors if errors.length > 0
	
	unitsIsValid: (units) ->
		isInteger(units) and units > 0
	
	attributeIsValid: (attr) ->
		typeof attr is 'number' and attr > 0
	
	totalAnnualUnitRent: ->
		rent = @get("monthlyRent")
		units = @get("units")
		return unless @attributeIsValid(rent) and @unitsIsValid(units)
		12 * rent * units
		
	totalSquareFeet: ->
		sf = @get("squareFeet")
		units = @get("units")
		return unless @attributeIsValid(sf) and @unitsIsValid(units)
		12 * sf * units