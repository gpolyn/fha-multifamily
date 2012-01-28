class TodoApp.OperatingView extends Backbone.View
	
	tagName: "div"
	
	# className: "operating"
	id: "operating"

	template: _.template "<div class='left'>net operating income</div><div class='right'><span id='net-operating-income'><%= netOperatingIncome %></span></div>"
	
	initialize: ->
		@model.bind "resizeLoan", => @render()
		$("#income").append(@render().el)
	
	render: ->
		# console?.log "OperatingView render where egi is #{@model.get('operatingIncome').effectiveGrossIncome()}"
		# console?.log "OperatingView render where opex total is #{@model.get('operatingExpense').get('total')}"
		noi = @model.netOperatingIncome()
		noi = TodoApp.dollarFormatting(noi) unless isNaN(noi)
		$(@el).html @template {netOperatingIncome: noi}
		@	