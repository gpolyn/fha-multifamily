TodoApp.template = (selector) ->
  template = null
  ->
    template ?= Handlebars.compile(if selector.charAt(0) == "#" then $(selector).html() else selector)
    template.apply this, arguments

class TodoApp.OperatingExpenseView extends Backbone.View
	
	tagName: "div"
	
	id: "operating-expense"
	
	template: TodoApp.template '#operating-expense-template'
	
	events:
		"keypress input#total"                     : "updateOnEnter"
		"change #totalOperatingExpenseIsPercent"   : "updateOnChange"
	
	initialize: ->
		console?.log "OperatingExpenseView initialize..."
		# _.bindAll this, 'close'
		# stored = @model.localStorage.findAll()[0]
		# attrs =
		# 	id:									  stored.id
		# 	total:                                stored.total
		# 	totalIsPercentOfEffectiveGrossIncome: stored.totalIsPercentOfEffectiveGrossIncome
		# currentModel = new TodoApp.OperatingExpense attrs
		# @model = currentModel
		@model.bind 'change', @render
		$("#income").append(@render().el);
		# @close()
		# console?.log "model local storage #{@model.localStorage.findAll()[0].id}"
		# @model.fetch()
		# console?.log "post fetch model id: #{@model.id}"
		# @setContent()
		# @render()
	
	render: =>
		$(@el).html @template @model.toJSON()
		@setContent()
		console?.log "just got back to render from setContent"
		@
	
	setContent: ->
		console?.log "OperatingExpenseView setContent..."
		@$('input#total').val @model.get 'total'
		@inputTotal = @$('input#total')
		@inputTotal.blur @close
		
		isPercent = @model.get 'totalIsPercentOfEffectiveGrossIncome'
		@$('input#totalOperatingExpenseIsPercent').prop("checked", isPercent) 
		@inputIsPercent = @$('input#totalOperatingExpenseIsPercent')
		@inputIsPercent.blur @close
	
	updateOnChange: ->
		console?.log "updateOnChange"
		if @inputIsPercent.is(':checked')
			total = parseInt(@inputTotal)
			console?.log "where I think!"
			@inputTotal.val('') if total > 100 or total < 0		
		@close()
	
	close: () =>
		console.log("OperatingExpenseView close")
		@model.save @readAttributes(), {error: => @render()}
	
	updateOnEnter: (e) ->
		@close() if e.keyCode == 13
	
	readAttributes: ->
		console?.log "readAttributes..."
		total:                                 parseInt @inputTotal.val()
		totalIsPercentOfEffectiveGrossIncome:  @inputIsPercent.is(':checked')