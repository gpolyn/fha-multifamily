class TodoApp.LoanService extends Backbone.Model
	
	url: "/sec223f_acquisition_loan"
	
	initialize: ->
		@criteria = @attributes.criteria
		@attributes.operating.bind "resizeLoan", => @updateOperatingHashAndGetLoan()
		@attributes.affordability.bind "change", => @updateAffordabilityHashAndGetLoan()
		@attributes.metropolitanArea.bind "change", => @updateMetropolitanAreaHashAndGetLoan()
		@attributes.loanCosts.bind "resizeLoan", => @updateLoanCostsHashAndGetLoan()
		@toJSONHash = 
			operating:        @attributes.operating.toJSON()
			affordability:    @attributes.affordability.toJSON()
			metropolitanArea: @attributes.metropolitanArea.toJSON()
			loanCosts:        @attributes.loanCosts.toJSON()
	
	updateOperatingHashAndGetLoan: ->
		@toJSONHash.operating = @attributes.operating.toJSON()
		@criteria.fetch({data: @toJSON()})
	
	updateAffordabilityHashAndGetLoan: ->
		@toJSONHash.affordability = @attributes.affordability.toJSON()
		@criteria.fetch({data: @toJSON()})
	
	updateMetropolitanAreaHashAndGetLoan: ->
		@toJSONHash.metropolitanArea = @attributes.metropolitanArea.toJSON()
		@criteria.fetch({data: @toJSON()})
	
	updateLoanCostsHashAndGetLoan: ->
		@toJSONHash.loanCosts = @attributes.loanCosts.toJSON()
		@criteria.fetch({data: @toJSON()})
	
	# fetchCriteriaWithCurrentInputData: ->
	# 	options = {data: @toJSON()}
	# 	@criteria.fetch {data: @toJSON()}
	
	# getLoan: (options) ->
	# 	options || (options = {})
	# 	collection = @criteria
	# 	success = options.success
	# 	options.success = (resp, status, xhr) ->
	# 		collection[options.add ? 'add' : 'refresh'](collection.parse(resp, xhr), options)
	# 		success(collection, resp) if (success)
	# 	
	# 	options.error = (resp) ->
	# 		if options.error
	# 			options.error collection, resp, options
	# 		else
	# 			collection.trigger 'error', collection, resp, options
	# 	
	# 	params =
	# 		type:     'GET'
	# 		dataType: 'json'
	# 		url:       @url
	# 		data:      @toJSON()  
	# 	
	# 	if Backbone.emulateJSON
	# 		params.contentType = 'application/x-www-form-urlencoded'
	# 		params.data        = if params.data then {model : params.data} else {}
	# 	
	# 	$.ajax(params)
	
	fetch: (options) ->
		throw new Error "Persistence-related actions not available in this class"
	
	save: (attrs, options) ->
		throw new Error "Persistence-related actions not available in this class"
	
	destroy: (options) ->
		throw new Error "Persistence-related actions not available in this class"
	
	toJSON: ->
		@toJSONHash
	