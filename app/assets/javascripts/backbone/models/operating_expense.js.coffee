class TodoApp.OperatingExpense extends Backbone.Model
	
	localStorage: new Store("operatingExpense")
	
	validate: (attrs) ->
		errors = []
		
		unless typeof attrs.total is 'number' and attrs.total > 0
			errors.push("Total operating expense must be greater than 0")
		
		if attrs.totalIsPercentOfEffectiveGrossIncome is true
			unless attrs.total <= 100
				errors.push("Total operating expense percent must be less than 100")
				
		errors if errors.length > 0
	
	toJSONWithoutIDParam: ->
		results = @toJSON()
		delete results.id
		results