class TodoApp.ElevatorStatus extends TodoApp.SingletonLikeModel
	
	@localStorage: -> new Store "elevatorStatus"
	
	localStorage: @localStorage()
	
	defaults:
	    "hasElevator":  false
		
	
	validate: (attrs) ->
		errors = []
		
		if [true, false].indexOf(attrs.hasElevator) is -1
			errors.push("hasElevator must be true or false")
		#console?.log "in errors #{errors[0]}, and hasElevator is, in fact #{attrs.hasElevator} and a string #{attrs.hasElevator == true}"		
		errors if errors.length > 0
	
	toJSON: ->
		hasElevator: @get('hasElevator')