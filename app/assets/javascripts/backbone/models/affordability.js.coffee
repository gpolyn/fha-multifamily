class TodoApp.Affordability extends TodoApp.SingletonLikeModel
	
	@localStorage: -> new Store "affordability"
	
	localStorage: @localStorage()
	
	validate: (attrs) ->
		errors = []
		
		if ["market", "affordable", "subsidized"].indexOf(attrs.level) is -1
			errors.push("Affordability must be one of 'market', 'affordable' or 'subsidized'")
				
		errors if errors.length > 0
	
	toJSON: ->
		level: @get('level')
	