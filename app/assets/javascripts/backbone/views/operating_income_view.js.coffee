TodoApp.template = (selector) ->
  template = null
  ->
    template ?= Handlebars.compile(if selector.charAt(0) == "#" then $(selector).html() else selector)
    template.apply this, arguments

class TodoApp.OperatingIncomeView extends Backbone.View
	
	tagName: "div"
	
	className: "operating-income"
		
	id: "operating-income"

	template: TodoApp.template '#operating-income-template'
	
	events:
		'blur input'     : 'close'
		"keypress input" : "updateOnEnter"
	
	initialize: ->
		@model.bind 'change', => @render()
		$("#income").append(@render().el)
		@handleCommercialOccupancyRequirement()
		@inputCommercialOccupancyPct = @$('input#commercial-occupancy-percent')
		@inputResidentialOccupancyPct = @$('input#residential-occupancy-percent')
	
	render: =>
		console?.log "OperatingIncomeView render"
		modifiedJSON = _.clone(@model.toJSON())
		modifiedJSON['grossCommercialIncome'] = TodoApp.dollarFormattingZeroPlaces(modifiedJSON['grossCommercialIncome'])		
		modifiedJSON['grossResidentialIncome'] = TodoApp.dollarFormattingZeroPlaces(modifiedJSON['grossResidentialIncome'])
		modifiedJSON['effectiveGrossIncome'] = TodoApp.dollarFormatting modifiedJSON['effectiveGrossIncome']
		
		unless modifiedJSON.residentialOccupancyPercent is undefined
			fmted = TodoApp.dollarFormatting modifiedJSON.effectiveGrossResidentialIncome
			modifiedJSON.effectiveGrossResidentialIncome = fmted
		
		unless modifiedJSON.commercialOccupancyPercent is undefined
			fmted = TodoApp.dollarFormatting modifiedJSON.effectiveGrossCommercialIncome
			modifiedJSON.effectiveGrossCommercialIncome = fmted
		
		$(@el).html @template modifiedJSON
		@handleCommercialOccupancyRequirement()
		@
	
	handleCommercialOccupancyRequirement: ->
		if @model.hasNoCommercialIncomeSources() is true
			if $('label#commercial-occupancy-percent > span.require').length is not 0
				$('label#commercial-occupancy-percent > span.require').remove()
		else
			if $('label#commercial-occupancy-percent > span.require').length is 0
				$("label[for='commercial-occupancy-percent']").html("occupancy rate<span class='required'>*</span>")
	
	close: () =>
		@model.save @readAttributes(), {error: => @render()}
	
	readAttributes: ->
		resPct = parseFloat @$('input#residential-occupancy-percent').val()
		resPct = -1 if isNaN(resPct)
		comPct = parseFloat @$('input#commercial-occupancy-percent').val()
		comPct = null if isNaN(comPct)
		id:                           @model.get 'id'
		commercialOccupancyPercent:   comPct #parseFloat @$('input#commercial-occupancy-percent').val()
		residentialOccupancyPercent:  resPct
	
	updateOnEnter: (e) ->
		@close() if e.keyCode == 13
	