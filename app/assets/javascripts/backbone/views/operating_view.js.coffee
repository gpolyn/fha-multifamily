class TodoApp.OperatingView extends Backbone.View
	
	tagName: "div"
	
	className: "operating"

	template: _.template "net operating income <span id='net-operating-income'><%= netOperatingIncome %></span>"
	
	initialize: ->
		@model.bind "resizeLoan", => @render()
		$("#income").append(@render().el)
	
	render: ->
		# console?.log "OperatingView render where egi is #{@model.get('operatingIncome').effectiveGrossIncome()}"
		# console?.log "OperatingView render where opex total is #{@model.get('operatingExpense').get('total')}"
		$(@el).html @template {netOperatingIncome: @model.netOperatingIncome()}
		@	