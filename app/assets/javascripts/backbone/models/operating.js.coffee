class TodoApp.Operating extends Backbone.Model
	
	initialize: ->
		@attributes.operatingIncome.bind "resizeLoan", => @changeHandler() #@triggger "resizeLoan"
		@attributes.operatingExpense.bind "change", => @changeHandler() #@trigger "resizeLoan"
	
	changeHandler: ->
		console?.log "Operating changeHandler"
		@trigger "resizeLoan"
		# @trigger "refreshedNetOperatingIncome" #, => @netOperatingIncome()
	
	netOperatingIncome: ->
		return unless egi = @get('operatingIncome').effectiveGrossIncome()
		opex = @get('operatingExpense')
		return unless opexTotal = opex.get('total')
		
		if opex.get('totalIsPercentOfEffectiveGrossIncome') is true
			(100 - parseFloat(opexTotal))/100 * egi
		else
			egi - opexTotal
	
	toJSON: ->
		ret = 
			operatingExpense: @get('operatingExpense').toJSONWithoutIDParam()
			operatingIncome:  @get('operatingIncome').toJSON()
			spaceUtilization: @get('operatingIncome').spaceUtilizationHash()