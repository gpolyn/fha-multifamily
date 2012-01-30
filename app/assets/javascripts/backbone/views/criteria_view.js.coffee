class TodoApp.LoanCriterionView extends Backbone.View
	
	tagName: "div"
	
	className: "loan-criterion"
	
	initialize: ->
		@template = TodoApp.template @options.templateId
		@id = @options.viewId
		@model.bind 'destroy', => @remove()
	
	render: =>
		modifiedJSON = _.clone(@model.toJSON())
		modifiedJSON['loanAmount'] = TodoApp.commaFormatted(new String(Math.round(modifiedJSON['loanAmount']))+".")
		modifiedJSON['criterionDescription'] = @obtainCriterionDescription modifiedJSON['criterion']
		$(@el).html @template modifiedJSON
		@
		
	obtainCriterionDescription: (criterionNumber) ->
		switch criterionNumber
			when 1 then "Loan request"
			when 3 then "Project value"
			when 4 then "Statutory limit"
			when 5 then "Debt service limit"
			when 7 then "Purchase transaction cost limit"
			when 10 then "Refinance transaction cost limit"
			when 11 then "Other capital sources limit"
	
class TodoApp.CriteriaView extends Backbone.View
	
	el: "#todoapp"
	
	template: TodoApp.template '#criteria-template'
	
	events:
		"change div#income input, div#acquisition-costs:not(#loan-service) input, div#elevator-status select" : "removeCurrent"
		"change div#metropolitan-area select" : "removeCurrent"
		"change div#affordability input" : "changeOMeter"

	initialize: ->
		@collection.bind 'refresh', @removeCurrent
		@collection.bind 'refresh', @renderConclusions
		@collection.bind 'refresh', @addAll
		
		_.bindAll this, 'addOne', 'addAll'
		@collection.bind 'add', @addOne

		if @options.loanService.hasLoanAmountAndCashRequirementSaved() 
			@renderConclusions() 
			@collection.fetch()
		
		$("#gif").ajaxStart () ->
			$("div#loan-result-summary").hide()
			$("div#loan-results").hide()
			$(this).css('margin-top', '20px').show()
		$("#gif").ajaxStop () ->
			$(this).hide()
			$("div#loan-result-summary").show()
			$("div#loan-results").show()
	
	addOne: (todo) =>
		console?.log "inside addOne"
		view = new TodoApp.LoanCriterionView {model: todo, templateId: "#loan-criterion", viewId: "anyId"}
		@$("#loan-results").append view.render().el

	# Add all items in the collection at once.
	addAll: =>
		console?.log "inside addAll"
		@collection.each @addOne
		
	removeCurrent: =>
		$('div.loan-criterion').remove()
		$('div#loan-result-summary').remove()
	
	setLoanService: (loanSvc) ->
		@loanService = loanSvc
		
	renderConclusions: =>
		console.log "renderConclusions"
		@$('#loan-results').html @template
			loanAmount:      TodoApp.dollarFormattingZeroPlaces @options.loanService.getLoanAmountFromLocalStorage() 
			cashRequirement: TodoApp.dollarFormattingZeroPlaces @options.loanService.getCashRequirementFromLocalStorage()
	
	changeOMeter: =>
		console.log "change detected from within criteria view"
	