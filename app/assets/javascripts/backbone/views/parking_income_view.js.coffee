TodoApp.template = (selector) ->
  template = null
  ->
    template ?= Handlebars.compile(if selector.charAt(0) == "#" then $(selector).html() else selector)
    template.apply this, arguments

class TodoApp.ParkingIncomeView extends Backbone.View
	
	tagName: "tr"
	
	# Cache the template function for a single item.
	template: TodoApp.template '#parking-income-template'
	
	events:
		"keypress input"                      : "updateOnEnter"
		"dblclick td:lt(4)"                   : "edit"
		"click span.parking-income-destroy"   : "destroy"
	
	initialize: ->
		# _.bindAll this, 'render', 'close'
		@model.bind 'change', @render # think this may be redundant with edit op'ns
		@model.bind 'destroy', => @remove() # GP - notice fat arrow here, and method not bound above
	
	render: =>
		$(@el).html @template @model.toJSON()
		@setContent()
		# console?.log "just got back to render from setContent"
		@
	
	setContent: ->
		outdoorOrIndoor = @model.get 'outdoorOrIndoor'
		monthlyFee = @model.get 'monthlyFee'
		spaces = @model.get 'spaces'
		squareFeet = @model.get 'squareFeet' # may need to make this contingent on whether sf exists...
		# console?.log "squareFeet is #{squareFeet}"

		@$('td.indoor-or-outdoor div.display').text outdoorOrIndoor
		@selectOutdoorOrIndoor = @$('td.indoor-or-outdoor select')
		@selectOutdoorOrIndoor.blur @close
		@selectOutdoorOrIndoor.val outdoorOrIndoor

		@$('td.spaces div.display').text spaces
		@inputSpaces = @$('td.spaces input')
		@inputSpaces.blur @close
		@inputSpaces.val spaces

		@$('td.total-square-feet div.display').text squareFeet
		@inputTotalSquareFeet = @$('td.total-square-feet input')
		@inputTotalSquareFeet.blur @close
		@inputTotalSquareFeet.val squareFeet

		# console?.log "monthlyRent is #{monthlyRent}"
		@$('td.monthly-fee div.display').text monthlyFee
		@inputMonthlyFee = @$('td.monthly-fee input')
		@inputMonthlyFee.blur @close
		@inputMonthlyFee.val monthlyFee
	
	edit: (e) ->
		$(@el).addClass "editing"
		# console?.log "ParkingIncomeView edit: parent node class #{e.target.parentNode.className}"
		switch e.target.parentNode.className
			when 'spaces' then @inputSpaces.focus()
			when 'indoor-or-outdoor' then @selectOutdoorOrIndoor.focus()
			when 'monthly-fee' then @inputMonthlyFee.focus()
			when 'total-square-feet' then @inputTotalSquareFeet.focus() # silly workaround for when field is blank...
			else @inputTotalSquareFeet.focus() if e.target.className is 'total-square-feet' # ...
	
	close: () =>
		# console.log("ApartmentIncomeView close")
		@model.save @readAttributes(), {error: => @render()}
		$(@el).removeClass "editing"
	
	updateOnEnter: (e) ->
		@close() if e.keyCode == 13
	
	destroy: ->
		# console.log "ApartmentIncomeView: destroy"
		@model.destroy()
	
	readAttributes: ->
		console?.log "ParkingIncomeView readAttributes, where monthly fee is #{}"
		sf = parseInt $.trim(@inputTotalSquareFeet.val())
		@model.unset "squareFeet", {silent: true} if isNaN(sf) and @model.previous("squareFeet")?

		if isNaN(sf) is true
			spaces:           parseInt @inputSpaces.val()
			monthlyFee:       parseInt @inputMonthlyFee.val()
			outdoorOrIndoor:  @selectOutdoorOrIndoor.val()
		else
			spaces:           parseInt @inputSpaces.val()
			monthlyFee:       parseInt @inputMonthlyFee.val()
			outdoorOrIndoor:  @selectOutdoorOrIndoor.val()
			squareFeet:       sf	
	

class TodoApp.CommercialParkingIncomeView extends TodoApp.ParkingIncomeView
	
	className: "commercial-parking-income"

class TodoApp.ResidentialParkingIncomeView extends TodoApp.ParkingIncomeView

	className: "residential-parking-income"
