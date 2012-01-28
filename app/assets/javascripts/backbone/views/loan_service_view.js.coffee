class TodoApp.LoanServiceView extends Backbone.View
	
	tagName: "div"
	
	id: "loan-service"
	
	template: TodoApp.template '#loan-service-template'
	
	events:
		"change input#api-key"     : "save"
		"click button#loan-submit" : "submitLoan"
	
	initialize: ->
		@model.loanSubmission.bind 'change', @render
		$("#acquisition-costs").append(@render().el)
	
	render: =>
		$(@el).html @template {apiKey: @model.loanSubmission.get('apiKey')}
		@
	
	save: ->
		@model.loanSubmission.save @readAttributes()
	
	readAttributes: ->
		{apiKey: TodoApp.getNullOrVal('input#api-key')}
		
	submitLoan: ->
		errors = @model.isValidForSubmission()
		if errors is true
			e =
				200 : (data, textStatus, jqXHR) ->
					ele = "<span id='api-key-uses-remaining'>API key uses remaining: " + 
					      jqXHR.getResponseHeader('Api-Key-Uses-Remaining') + "</span>"
					$('#submit-response-message-container').html ele
					
				401: (jqXHR, textStatus, errorThrown) ->
					$('input#api-key').css({"background-color": '#f11'}).
						keyup (e) -> $(this).css("background-color", 'transparent').unbind("keyup", arguments.callee)
					ele = "<span id='failure-msg'>API key invalid</span>"
					$('div#submit-response-message-container').html ele
					$('span#failure-msg').css("color", '#f11').delay(2500).fadeOut(1000).queue () -> 
						$(this).remove()
				500: (jqXHR, textStatus, errorThrown) ->
					msgSpan = "<span id='failure-msg'>Service not responding, try later</span>"
					$('div#submit-response-message-container').html msgSpan
					$('span#failure-msg').css("color", '#f11').delay(2500).fadeOut(1000).queue () -> 
						$(this).remove()
				
			@model.fetch({statusCode: e});
		else
			for err in errors
				ele = null
				
				ele = switch err
					when "apiKey"
						'input#api-key'
					when "transactionAmount"
						'input#transaction-amount'
					when "termInMonths"
						'input#term-in-months'
					when "loanRequest"
						'input#loan-request'
					when "mortgageInterestRate"
						'input#mortgage-interest-rate'
					when "apartmentIncome"
						'table#apartment-income tbody tr:first input:not(.apartment-square-feet)'
					when "commercialOccupancyPercent"
						"input#commercial-occupancy-percent"
					when "operatingExpense"
						"div#operating-expense input#total"
					when "value"
						'input#value'
				$('span.api-key-uses-remaining').hide()
				$(ele).css("background-color", '#f11')
				$('div#submit-response-message-container').html "<span id='failure-msg'>submit all required fields</span>"
				$('span#failure-msg').css("color", '#f11').delay(2500).fadeOut(1000).queue () -> 
					$(this).remove()
					$('span.api-key-uses-remaining').show()
				
				$(ele).keyup (e) ->
					$(this).css("background-color", 'transparent').unbind("keyup", arguments.callee)
					