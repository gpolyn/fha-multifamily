TodoApp.template = (selector) ->
  template = null
  ->
    template ?= Handlebars.compile(if selector.charAt(0) == "#" then $(selector).html() else selector)
    template.apply this, arguments

class TodoApp.OperatingIncomeView extends Backbone.View
	
	tagName: "div"
	
	className: "operating-income"

	template: TodoApp.template '#operating-income-template'
	
	events:
		'blur input'     : 'close'
		"keypress input" : "updateOnEnter"
	
	initialize: ->
		@model.bind 'change', => @render()
		$("#income").append(@render().el)
		
		@inputCommercialOccupancyPct = @$('input#commercial-occupancy-percent')
		@inputResidentialOccupancyPct = @$('input#residential-occupancy-percent')
	
	render: =>
		console?.log "OperatingIncomeView render"
		$(@el).html @template @model.toJSON()
		@
	
	close: () =>
		console?.log "OperatingIncomeView close..."
		console?.log "...res pct atr is #{@readAttributes().residentialOccupancyPercent}"
		console?.log "...comm pct atr is #{@readAttributes().commercialOccupancyPercent}"
		console?.log "...id is #{@readAttributes().id}"
		@model.save @readAttributes(), {error: => @render()}
	
	readAttributes: ->
		resPct = parseFloat @$('input#residential-occupancy-percent').val()
		resPct = -1 if isNaN(resPct)
		id:                           @model.get 'id'
		commercialOccupancyPercent:   parseFloat @$('input#commercial-occupancy-percent').val()
		residentialOccupancyPercent:  resPct
	
	updateOnEnter: (e) ->
		@close() if e.keyCode == 13
	