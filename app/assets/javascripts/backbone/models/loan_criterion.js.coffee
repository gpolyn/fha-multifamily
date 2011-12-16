class TodoApp.LoanCriterion extends Backbone.Model
	
	validate: (attrs) ->
		errors = []
		unless attrs.loanAmount >= 0
			errors.push "Loan amount must be greater than or equal to 0"
		unless [1, 3, 4, 5, 7].indexOf(attrs.criterion) is -1
			errors.push "Criterion must be one of 1, 3, 4, 5 or 7"		
		errors if errors.length > 0
	
class TodoApp.LoanCriteria extends Backbone.Collection
	
	url: "/sec223f_acquisition_loan"
	
	model: TodoApp.LoanCriterion
	
	comparator: (criterion) ->
		criterion.get('loanAmount')
	
	# fetch: (options) ->
	# 	console?.log "fetch"
	# 	item1 = new TodoApp.LoanCriterion {loanAmount: 200, criterion: 3}
	# 	item2 = new TodoApp.LoanCriterion {loanAmount: 400, criterion: 4}
	# 	item3 = new TodoApp.LoanCriterion {loanAmount: 300, criterion: 5}
	# 	item4 = new TodoApp.LoanCriterion {loanAmount: 500, criterion: 7}
	# 	@refresh [item1, item2, item3, item4]
	
	limitingCriterion: ->
		return if @isEmpty()
		@at(0).get('criterion')
	
	loanAmount: ->
		return if @isEmpty()
		@at(0).get('loanAmount')
	
	parse: (res) ->
		res.response.criteria
	
	fetch: (options) ->
		options || (options = {})
		collection = @
		success = options.success
		options.success = (resp) ->
			collection[if options.add then 'add' else 'refresh'](collection.parse(resp), options)
			success(collection, resp) if (success)
		
		error = options.error
		options.error = (resp) ->
			if error
				error collection, resp, options
			else
				collection.trigger 'error', collection, resp, options
		
		params =
			type:        'GET'
			dataType:    'json'
			url:          @url
			contentType: 'application/json'
				
		if Backbone.emulateJSON
			params.contentType = 'application/x-www-form-urlencoded'
			params.data        = if options.data then {model : options.data} else {}
			
		_.extend params, options
		$.ajax(params)
		@
	