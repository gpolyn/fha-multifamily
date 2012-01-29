# Todo Item View
# --------------

TodoApp.template = (selector) ->
  template = null
  ->
    template ?= Handlebars.compile(if selector.charAt(0) == "#" then $(selector).html() else selector)
    template.apply this, arguments

# The DOM element for a todo item...
class TodoApp.ApartmentIncomeView extends Backbone.View
	
	tagName: "tr"
	
	className: "apartment-income"
	
	# Cache the template function for a single item.
	# template: TodoApp.template '#item-template'
	template: TodoApp.template '#apartment-income-template'

	# The DOM events specific to an item.
	events:
		"keypress input"                        : "updateOnEnter"
		"click span.apartment-income-destroy"   : "destroy"
		"dblclick tr.apartment-income td"       : "edit"

	# The TodoView listens for changes to its model, re-rendering. Since there's
	# a one-to-one correspondence between a **Todo** and a **TodoView** in this
	# app, we set a direct reference on the model for convenience.
	initialize: ->
		# _.bindAll this, 'render', 'close'
		@model.bind 'change', @render # think this may be redundant with edit op'ns
		@model.bind 'destroy', => @remove() # GP - notice fat arrow here, and method not bound above

	# Re-render the contents of the todo item.
	render: =>
		console?.log "ApartmentIncomeView: render"
		$(@el).html @template @model.toJSON()
		@setContent()
		console?.log "just got back to render from setContent"
		@

  # To avoid XSS (not that it would be harmful in this particular app),
  # we use `jQuery.text` to set the contents of the todo item.
	setContent: ->
		console?.log "ApartmentIncomeView: setContent"
		
		bedrooms = @model.get 'bedrooms'
		monthlyRent = @model.get 'monthlyRent'
		units = @model.get 'units'
		squareFeet = @model.get 'squareFeet' # may need to make this contingent on whether sf exists...
		console?.log "squareFeet is #{squareFeet}"
		
		@$('td.bedroom-count div.display').text bedrooms
		@selectBedrooms = @$('td.bedroom-count select')
		@selectBedrooms.blur @close
		@selectBedrooms.val bedrooms
		
		@$('td.unit-count div.display').text units
		@inputUnits = @$('td.unit-count input')
		@inputUnits.blur @close
		@inputUnits.val units
		
		@$('td.square-feet div.display').text squareFeet
		@inputSquareFeet = @$('td.square-feet input')
		@inputSquareFeet.blur @close
		@inputSquareFeet.val squareFeet
		
		console?.log "monthlyRent is #{monthlyRent}"
		@$('td.monthly-rent div.display').text monthlyRent
		@inputMonthlyRent = @$('td.monthly-rent input')
		@inputMonthlyRent.blur @close
		@inputMonthlyRent.val monthlyRent
		console?.log "ApartmentIncomeView: about to leave setContent"

	# Switch this view into `"editing"` mode, displaying the input field.
	edit: (e) ->
		console?.log "ApartmentIncomeView edit"
		# console.log("ApartmentIncomeView: edit in #{e.target.parentNode.className}")
		# console.log("ApartmentIncomeView: edit in #{e.target.parentNode.className}")
		# console.log("ApartmentIncomeView: and edit in #{e.target.className}")
		$(@el).addClass "editing"
		
		switch e.target.parentNode.className
			when 'unit-count' then @inputUnits.focus()
			when 'bedroom-count' then @selectBedrooms.focus()
			when 'monthly-rent' then @inputMonthlyRent.focus()
			when 'square-feet' then @inputSquareFeet.focus() # silly workaround for when field is blank...
			else @inputSquareFeet.focus() if e.target.className is 'square-feet' # ...
	
	# abortive attempt at metaprogramming
	# for k, v of ['get', 'set']
	# 	do (k, v) ->
	# 		console.log('creating method: ' + v)
	# 		TodoApp.ApartmentIncomeView::[v] = ->
	# 			method = 
	# 			console.log('executing method: ' + method)
	
  # Close the `"editing"` mode, saving changes to the todo.
	close: () =>
		console.log("ApartmentIncomeView close")
		@model.save @readAttributes(), {error: => @render()}
		$(@el).removeClass "editing"
	
  # If you hit `enter`, we're through editing the item.
	updateOnEnter: (e) ->
		@close() if e.keyCode == 13
	
  # Destroy the model.
	destroy: ->
		console.log "ApartmentIncomeView: destroy"
		@model.destroy()
	
	readAttributes: ->
		console?.log "ApartmentIncomeView readAttributes"
		sf = parseInt $.trim(@inputSquareFeet.val())
		@model.unset "squareFeet", {silent: true} if isNaN(sf) and @model.previous("squareFeet")?
		
		if isNaN(sf) is true
			bedrooms:      parseInt @selectBedrooms.val()
			monthlyRent:   parseInt @inputMonthlyRent.val()
			units:         parseInt @inputUnits.val()
		else
			bedrooms:      parseInt @selectBedrooms.val()
			monthlyRent:   parseInt @inputMonthlyRent.val()
			units:         parseInt @inputUnits.val()
			squareFeet:    sf
	