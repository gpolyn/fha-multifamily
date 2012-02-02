class TodoApp.Sec223fCostsView extends Backbone.View
	
	# tagName: "div"
	
	# id: "acquisition-costs"
	
	template: TodoApp.template '#sec223f-acquisition-costs-template'
	
	events:
		"change input"                           : "save"
		"change input[name*='purchase-or-debt']" : "updateValueRequirement"
		# 'blur input'     : 'render'
		# "keypress input" : "save"
		# "change input#value"           : "valueFieldHasBeenExplicitlySet"
		# "change #totalOperatingExpenseIsPercent"   : "updateOnChange"
	
	initialize: ->
		$("#acquisition-costs").append(@render().el)
		@updateValueRequirement()
		
		# events =
		# 	"change input:not(.required)"  : "testing"
		# 	"change input.required"        : "otherTesting"
		# 	
		# if @model.isNew()
		# 	@disableAllOptionalFields()
		# @delegateEvents events
	
	render: =>
		console?.log "inside render"
		$(@el).html @template @model.toJSON() # this won't matter in this case (?)
		@setContent()
		@
	
	setContent: ->
		console?.log "loan costs view setContent..."
		
		@$("input#" + @model.get 'transactionAmountType').attr('checked', true)
		@$('input#financing-fee-percent').attr('checked', @model.get 'financingFeeIsPercentOfLoan')
		@$('input#title-and-recording-percent').attr('checked', @model.get 'titleAndRecordingIsPercentOfLoan')
		@updateValueRequirement()
		# @$("input#" + @model.get 'transactionAmountType').attr('checked', true)
		
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
	
	# disableAllOptionalFields: ->
	# 	@$('input').not('.required').attr('disabled', true)
	# 
	# enableAllOptionalFields: ->
	# 	@$('input').not('.required').attr('disabled', false)
	# 
	# toggleDisabledForOptionalFields: ->
	# 	@optionalFieldsAreDisabled ?= true
	# 	@$('input').not('.required').attr('disabled', @optionalFieldsAreDisabled)
	
	updateValueRequirement: ->
		console?.log "inside update value requirement"
		if @$('input[name=purchase-or-debt]:checked', '#transaction-amount-type-selector').val() == "debt"
			@$('input#value').removeClass "optional"
			@$('input#value').addClass "required"
			@$('<span class="required" id="value-span">*</span>').insertBefore('input#value')
		else
			@$('input#value').removeClass "required"
			@$('input#value').addClass "optional"
			@$('span#value-span').remove()
	
	getNullOrVal: (cssSelectorStr) ->
		if (val = jQuery.trim(@$(cssSelectorStr).val())) is "" then null else val
	
	readAttributes: ->
		transactionAmount:                @getNullOrVal 'input#transaction-amount'
		landValue:                        @getNullOrVal 'input#land-value'
		loanRequest:                      @getNullOrVal 'input#loan-request'
		transactionAmountType:            @$('input[name=purchase-or-debt]:checked', '#transaction-amount-type-selector').val()
		termInMonths:                     @getNullOrVal 'input#term-in-months'
		mortgageInterestRate:             @getNullOrVal 'input#mortgage-interest-rate'
		value:                            @getNullOrVal 'input#value'
		repairsOrImprovements:            @getNullOrVal 'input#repairs-or-improvements'
		annualReplacementReservesPerUnit: @getNullOrVal 'input#annual-replacement-reserves-per-unit'
		financingFee:                     @getNullOrVal 'input#financing-fee'
		financingFeeIsPercentOfLoan:      @$('input#financing-fee-percent').is(':checked')
		titleAndRecording:                @getNullOrVal 'input#title-and-recording'
		titleAndRecordingIsPercentOfLoan: @$('input#title-and-recording-percent').is(':checked')
		thirdPartyReports:                @getNullOrVal 'input#third-party-reports'
		survey:                           @getNullOrVal 'input#survey'
		legalAndOrganizational:           @getNullOrVal 'input#legal-and-organizational'
		other:                            @getNullOrVal 'input#other'
	
	save: ->
		@model.save @readAttributes(), {error: => @render()}
	