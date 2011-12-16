class TodoApp.Sec223fCostsView extends Backbone.View
	
	tagName: "div"
	
	id: "acquisition-costs"
	
	template: TodoApp.template '#sec223f-acquisition-costs-template'
	
	# events:
	# 	"change input:not(.required)"  : "testing"
	# 	"change input.required"        : "otherTesting"
		
		# "change input#value"           : "valueFieldHasBeenExplicitlySet"
		# "change #totalOperatingExpenseIsPercent"   : "updateOnChange"
	
	initialize: ->
		@model.bind 'change', @render
		$("#income").append(@render().el)
		
		events =
			"change input:not(.required)"  : "testing"
			"change input.required"        : "otherTesting"
			
		if @model.isNew()
			@disableAllOptionalFields()
			events["change input#purchase-price"] = "setValueFieldToPurchasePrice"
		@delegateEvents events
	
	render: =>
		$(@el).html @template @model.toJSON() # this won't matter in this case (?)
		@setContent()
		# console?.log "just got back to render from setContent"
		@
	
	setContent: ->
		# console?.log "OperatingExpenseView setContent..."
		# @$('input#total').val @model.get 'total'
		# @inputTotal = @$('input#total')
		# @inputTotal.blur @close
		# 
		# isPercent = @model.get 'totalIsPercentOfEffectiveGrossIncome'
		# @$('input#totalOperatingExpenseIsPercent').prop("checked", isPercent) 
		# @inputIsPercent = @$('input#totalOperatingExpenseIsPercent')
		# @inputIsPercent.blur @close
	
	# valueFieldHasBeenExplicitlySet: ->
	# 	unless @model.value?
	# 		# @valueFieldHasBeenExplicitlySet = true
	# 		@.unbind("change input#value", valueFieldHasBeenExplicitlySet)
	
	setValueFieldToPurchasePrice: ->
		console.log "setValueFieldToPurchasePrice"
		# @$('input#') # NOTE: Should set this when model avail, not otherwise...
	
	testing: ->
		console.log "TESTING!"
	
	otherTesting: ->
		console.log "OTHER TESTING!"
		console.log "JSON.stringify(@readAttributes()) #{JSON.stringify(@readAttributes())}"
		attrs = @readAttributes()
		if attrs.purchasePrice? and attrs.mortgageInterestRate?
			console.log "this would be valid"
			@enableAllOptionalFields()
		else
			@disableAllOptionalFields()
			console.log "this would not be valid"
	
	disableAllOptionalFields: ->
		@$('input').not('.required').attr('disabled', true)
	
	enableAllOptionalFields: ->
		@$('input').not('.required').attr('disabled', false)
	
	toggleDisabledForOptionalFields: ->
		@optionalFieldsAreDisabled ?= true
		@$('input').not('.required').attr('disabled', @optionalFieldsAreDisabled)
	
	readAttributes: ->
		attrs = 
			purchasePrice:         parseInt @$('input#purchase-price').val()
			mortgageInterestRate:  parseFloat @$('input#mortgage-interest-rate').val()
			repairsOrImprovements: parseInt @$('input#repairs-or-improvements').val()
			financingFee: parseFloat @$('input#financing-fee').val()
			financingFeePercent: @$('input#financing-fee-percent').is(':checked')
			replacementReservesOnDeposit: parseInt @$('input#replacement-reserve-on-deposit').val()
			annualReplacementReservesPerUnit: parseInt @$('input#annual-replacement-reserves-per-unit').val()
			initialDepositToReplacementReserve: parseInt @$('input#initial-deposit-to-replacement-reserve').val()
			majorMovableEquipment: parseInt @$('input#major-movable-equipment').val()
		_.each(attrs, (val, key) -> delete attrs[key] if isNaN val)
		attrs
	
	saveToModel: ->
		console.log "Sec223fCostsView saveToModel"
	