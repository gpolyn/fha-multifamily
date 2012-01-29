TodoApp.template = (selector) ->
  template = null
  ->
    template ?= Handlebars.compile(if selector.charAt(0) == "#" then $(selector).html() else selector)
    template.apply this, arguments

class TodoApp.SimpleIncomeView extends Backbone.View
	
	tagName: "tr"
	
	template: TodoApp.template "#simple-income-source-template"
	
	initialize: ->
		@model.bind 'change', @render # think this may be redundant with edit op'ns
		@model.bind 'destroy', => @remove() # GP - notice fat arrow here, and method not bound above
	
	edit: (e) ->
		$(@el).addClass "editing"
		# console?.log "ParkingIncomeView edit: parent node class #{e.target.parentNode.className}"
		switch e.target.parentNode.className
			when 'use' then @inputUsage.focus()
			when 'monthly-rent' then @inputMonthlyRent.focus()
			when 'square-feet' then @inputSquareFeet.focus() # silly workaround for when field is blank...
			else @inputSquareFeet.focus() if e.target.className is 'square-feet' # ...

	close: () =>
		console.log("SimpleIncomeView close, where usage is #{@readAttributes().usage}")
		@model.save @readAttributes(), {error: => @render()}
		$(@el).removeClass "editing"
	
	updateOnEnter: (e) ->
		@close() if e.keyCode == 13

	destroy: ->
		# console.log "ApartmentIncomeView: destroy"
		@model.destroy()
	
	
	events:
		"keypress input"                                : "updateOnEnter"
		"dblclick tr td"                                : "edit"
		"click span.simple-income-source-destroy"       : "destroy"
	
	render: =>
		$(@el).html @template @model.toJSON()
		@setContent()
		@
	
	setContent: ->
		monthlyRent = @model.get 'monthlyRent'
		squareFeet = @model.get 'squareFeet'
		usage = @model.get 'usage'

		@$('td.use div.display').text usage
		@inputUsage = @$('td.use input')
		@inputUsage.blur @close
		@inputUsage.val usage

		@$('td.square-feet div.display').text squareFeet
		@inputSquareFeet = @$('td.square-feet input')
		@inputSquareFeet.blur @close
		@inputSquareFeet.val squareFeet

		@$('td.monthly-rent div.display').text monthlyRent
		@inputMonthlyRent = @$('td.monthly-rent input')
		@inputMonthlyRent.blur @close
		@inputMonthlyRent.val monthlyRent
	
	readAttributes: ->
		console?.log "readAttributes..."
		sf = parseInt $.trim(@inputSquareFeet.val())
		use = @inputUsage.val()
		console?.log "...usage... #{use}..."
		# 	console?.log "...sf isNaN #{isNaN(sf)}..."
		# @model.set "usage"
		@model.unset "squareFeet", {silent: true} if isNaN(sf) and @model.previous("squareFeet")?

		if isNaN(sf) is true
			usage:            use
			monthlyRent:      parseInt @inputMonthlyRent.val()
		else	
		    usage:            use
			monthlyRent:      parseInt @inputMonthlyRent.val()
			squareFeet:       sf

class TodoApp.OtherResidentialIncomeView extends TodoApp.SimpleIncomeView

	className: "other-residential-income"

class TodoApp.CommercialIncomeView extends TodoApp.SimpleIncomeView

	className: "commercial-income"
