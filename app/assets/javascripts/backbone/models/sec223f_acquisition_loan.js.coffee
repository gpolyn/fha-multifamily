class TodoApp.Sec223fAcquisitionLoan extends Backbone.Model
	
	url: "/sec223f_acquisition_loan"
	
	parse: (res) ->
		console?.log "Sec223fAcquisitionLoan parse..."
	
	fetch: (options) ->
		# console?.log "options has success? #{options.success?}"
		params =
			type:         'GET'
			dataType:     'json'
			url:          @url
		_.extend(params, options)
		# options || (options = {})
		# model = @
		# success = options.success
		# options.success = (resp, status, xhr) ->
		# 	return false if not model.set(model.parse(resp, xhr), options)
		# 	success(model, resp) if success
		# # options.error = wrapError(options.error, model, options)
		#
		
		$.ajax(params)
